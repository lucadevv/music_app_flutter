import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/services/audio_handler_service.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/data/offline/models/offline_history.dart';
import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/domain/usecases/get_stream_url_usecase.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';

part 'player_bloc_event.dart';
part 'player_bloc_state.dart';

class PlayerBlocBloc extends Bloc<PlayerBlocEvent, PlayerBlocState> {
  final ApiServices _apiServices;
  late final GetStreamUrlUseCase _getStreamUrlUseCase;

  // AudioPlayer se obtiene de forma lazy para evitar dependencia circular
  // AudioPlayerHandler se registra en main.dart después de AudioService.init()
  AudioPlayer? _audioPlayerInstance;

  /// Getter para acceder al AudioPlayer
  AudioPlayer get _audioPlayer {
    if (_audioPlayerInstance == null) {
      throw Exception('Player not initialized');
    }
    return _audioPlayerInstance!;
  }

  PlayerBlocBloc(this._apiServices) : super(const PlayerBlocInitial()) {
    _getStreamUrlUseCase = GetIt.I<GetStreamUrlUseCase>();
    _registerEventHandlers();
    // No inicializar streams aquí - se hará cuando el player esté disponible
    // Inicializar el handler de audio después de un pequeño delay para asegurar que todo esté listo
    Future.microtask(() {
      add(const InitializeAudioServiceEvent());
    });
  }

  // OfflineService se obtiene de forma lazy para evitar dependencia circular
  OfflineService? _offlineService;

  late StreamSubscription _playerStateSubscription;
  late StreamSubscription _positionSubscription;
  late StreamSubscription _durationSubscription;
  late StreamSubscription _bufferedPositionSubscription;
  late StreamSubscription _currentIndexSubscription;

  // Flag para evitar inicialización múltiple de streams
  bool _isPlayerInitialized = false;

  // ==================== Historial de reproducción ====================
  /// ID de la entrada de historial actual
  String? _currentHistoryId;

  /// Última posición guardada en el historial (en segundos)
  /// Se usa para evitar guardar en cada cambio de posición
  int _lastSavedPositionSeconds = 0;

  /// Intervalo mínimo entre actualizaciones de historial (en segundos)
  static const int _historyUpdateIntervalSeconds = 5;

  /// Obtiene el OfflineService de forma lazy
  Future<OfflineService?> _getOfflineService() async {
    if (_offlineService != null) return _offlineService;

    try {
      if (GetIt.I.isRegistered<OfflineService>()) {
        _offlineService = await GetIt.I.getAsync<OfflineService>();
        return _offlineService;
      }
    } catch (e) {
      // Silently fail - no es crítico
    }
    return null;
  }

  // ==================== Métodos de Historial ====================

  /// Guarda la duración reproducida de la entrada de historial actual
  /// Es "fire and forget" - no bloquea la reproducción
  Future<void> _saveHistoryPlayedDuration(int positionSeconds) async {
    if (_currentHistoryId == null) return;

    // Evitar guardar si la posición no cambió significativamente
    if (positionSeconds - _lastSavedPositionSeconds <
        _historyUpdateIntervalSeconds) {
      return;
    }

    _lastSavedPositionSeconds = positionSeconds;

    // Fire and forget - no esperamos el resultado
    await _saveHistoryPlayedDurationInternal(
      _currentHistoryId!,
      positionSeconds,
    );
  }

  /// Implementación interna del guardado de historial
  Future<void> _saveHistoryPlayedDurationInternal(
    String historyId,
    int positionSeconds,
  ) async {
    try {
      final offlineService = await _getOfflineService();
      if (offlineService != null && offlineService.isInitialized) {
        await offlineService.updateHistoryPlayedDuration(
          historyId,
          positionSeconds,
        );
      }
    } catch (e) {
      // No propagar el error - el historial no debe afectar la reproducción
    }
  }

  /// Actualiza el mediaItem del AudioHandler para que muestre la canción en la notificación
  void _updateHandlerMediaItem(NowPlayingData track) {
    try {
      if (GetIt.I.isRegistered<AudioPlayerHandler>()) {
        final handler = GetIt.I<AudioPlayerHandler>();
        final mediaItem = track.toMediaItem();
        handler.mediaItem.add(mediaItem);
      }
    } catch (e) {
      // Silently fail - no es crítico
    }
  }

  /// Finaliza la entrada de historial actual y crea una nueva para el track
  Future<void> _startNewHistoryEntry(NowPlayingData track) async {
    // Primero, guardar el estado del historial anterior si existe
    await _finalizeCurrentHistoryEntry();

    try {
      final offlineService = await _getOfflineService();
      if (offlineService == null || !offlineService.isInitialized) {
        return;
      }

      // Obtener el nombre del artista
      final String artistName;
      if (track.artists.isNotEmpty) {
        artistName = track.artists.map((a) => a.name).join(', ');
      } else {
        artistName = 'Unknown Artist';
      }

      // Obtener la URL del thumbnail (usar .last para mejor calidad)
      String? thumbnailUrl;
      if (track.thumbnail != null) {
        thumbnailUrl = track.thumbnail?.url;
      } else if (track.thumbnails.isNotEmpty) {
        thumbnailUrl = track.thumbnails.last.url;
      }

      // Crear nueva entrada de historial
      final history = OfflineHistory.create(
        songId: track.videoId, // Usamos videoId como songId si no hay otro
        videoId: track.videoId,
        title: track.title,
        artist: artistName,
        thumbnail: thumbnailUrl,
        duration: track.durationSeconds,
        playedAt: DateTime.now(),
      );

      await offlineService.addToHistory(history);

      // Actualizar tracking
      _currentHistoryId = history.historyId;
      _lastSavedPositionSeconds = 0;
    } catch (e) {
      // No propagar el error - el historial no debe afectar la reproducción
    }
  }

  /// Finaliza la entrada de historial actual
  Future<void> _finalizeCurrentHistoryEntry() async {
    if (_currentHistoryId == null) return;

    try {
      // Guardar la posición final
      await _saveHistoryPlayedDurationInternal(
        _currentHistoryId!,
        _lastSavedPositionSeconds,
      );
    } catch (e) {
      // Silently fail
    } finally {
      // Limpiar estado
      _currentHistoryId = null;
      _lastSavedPositionSeconds = 0;
    }
  }

  void _initializePlayer() {
    // Evitar inicialización múltiple
    if (_isPlayerInitialized) {
      return;
    }

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      add(AudioPlayerStateChangedEvent(playerState));
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      add(PositionChangedEvent(position));
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      add(DurationChangedEvent(duration ?? Duration.zero));
    });

    _bufferedPositionSubscription = _audioPlayer.bufferedPositionStream.listen(
      (bufferedPosition) => add(BufferedPositionChangedEvent(bufferedPosition)),
    );

    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen(
      (index) => add(CurrentIndexChangedEvent(index)),
    );

    _isPlayerInitialized = true;
  }

  void _registerEventHandlers() {
    on<PlayEvent>(_onPlay);
    on<PauseEvent>(_onPause);
    on<StopEvent>(_onStop);
    on<PlayPauseToggleEvent>(_onPlayPauseToggle);

    on<NextTrackEvent>(_onNextTrack);
    on<PreviousTrackEvent>(_onPreviousTrack);
    on<SeekEvent>(_onSeek);

    on<LoadTrackEvent>(_onLoadTrack);
    on<LoadPlaylistEvent>(_onLoadPlaylist);
    on<PlayTrackAtIndexEvent>(_onPlayTrackAtIndex);
    on<AddToPlaylistEvent>(_onAddToPlaylist);
    on<RemoveFromPlaylistEvent>(_onRemoveFromPlaylist);

    on<SetVolumeEvent>(_onSetVolume);
    on<SetSpeedEvent>(_onSetSpeed);
    on<SetLoopModeEvent>(_onSetLoopMode);
    on<ToggleShuffleEvent>(_onToggleShuffle);

    on<AudioPlayerStateChangedEvent>(_onAudioPlayerStateChanged);
    on<PositionChangedEvent>(_onPositionChanged);
    on<DurationChangedEvent>(_onDurationChanged);
    on<BufferedPositionChangedEvent>(_onBufferedPositionChanged);
    on<CurrentIndexChangedEvent>(_onCurrentIndexChanged);
    on<AudioErrorEvent>(_onAudioError);

    on<InitializeAudioServiceEvent>(_onInitializeAudioService);
    on<DisposeAudioServiceEvent>(_onDisposeAudioService);
  }

  Future<void> _onPlay(PlayEvent event, Emitter<PlayerBlocState> emit) async {
    try {
      await _audioPlayer.play();

      // IMPORTANTE: Emitir estado inmediatamente para actualizar la UI
      // No depender solo del stream, ya que puede no estar inicializado
      if (state is PlayerBlocLoaded) {
        emit(
          (state as PlayerBlocLoaded).copyWith(
            playbackState: PlaybackState.playing,
            processingState: ProcessingState.ready,
          ),
        );
      } else {
        emit(
          const PlayerBlocLoaded(
            playbackState: PlaybackState.playing,
            processingState: ProcessingState.ready,
            connectionState: AudioConnectionState.connected,
          ),
        );
      }
    } catch (e) {
      add(AudioErrorEvent('Error al reproducir: $e'));
    }
  }

  Future<void> _onPause(PauseEvent event, Emitter<PlayerBlocState> emit) async {
    try {
      await _audioPlayer.pause();

      // IMPORTANTE: Emitir estado inmediatamente para actualizar la UI
      if (state is PlayerBlocLoaded) {
        emit(
          (state as PlayerBlocLoaded).copyWith(
            playbackState: PlaybackState.paused,
          ),
        );
      } else {
        emit(
          const PlayerBlocLoaded(
            playbackState: PlaybackState.paused,
            connectionState: AudioConnectionState.connected,
          ),
        );
      }
    } catch (e) {
      add(AudioErrorEvent('Error al pausar: $e'));
    }
  }

  Future<void> _onStop(StopEvent event, Emitter<PlayerBlocState> emit) async {
    try {
      // Finalizar entrada de historial actual antes de detener
      await _finalizeCurrentHistoryEntry();

      await _audioPlayer.stop();
      if (state is PlayerBlocLoaded) {
        emit(
          (state as PlayerBlocLoaded).copyWith(
            playbackState: PlaybackState.stopped,
            position: Duration.zero,
          ),
        );
      }
    } catch (e) {
      add(AudioErrorEvent('Error al detener: $e'));
    }
  }

  Future<void> _onPlayPauseToggle(
    PlayPauseToggleEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    if (state is PlayerBlocLoaded) {
      final currentState = state as PlayerBlocLoaded;
      if (currentState.isPlaying) {
        add(const PauseEvent());
      } else {
        add(const PlayEvent());
      }
    }
  }

  Future<void> _onNextTrack(
    NextTrackEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      if (state is PlayerBlocLoaded) {
        final currentState = state as PlayerBlocLoaded;
        if (currentState.canPlayNext) {
          await _audioPlayer.seekToNext();
        }
      }
    } catch (e) {
      add(AudioErrorEvent('Error al cambiar a siguiente: $e'));
    }
  }

  Future<void> _onPreviousTrack(
    PreviousTrackEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      if (state is PlayerBlocLoaded) {
        final currentState = state as PlayerBlocLoaded;
        if (currentState.canPlayPrevious) {
          await _audioPlayer.seekToPrevious();
        }
      }
    } catch (e) {
      add(AudioErrorEvent('Error al cambiar a anterior: $e'));
    }
  }

  Future<void> _onSeek(SeekEvent event, Emitter<PlayerBlocState> emit) async {
    try {
      await _audioPlayer.seek(event.position);
    } catch (e) {
      add(AudioErrorEvent('Error al hacer seek: $e'));
    }
  }

  Future<void> _onLoadTrack(
    LoadTrackEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      // Crear entrada de historial para el nuevo track (fire and forget)
      // Se hace antes de emitir el estado para que no bloquee la UI
      unawaited(_startNewHistoryEntry(event.track));

      emit(
        PlayerBlocLoaded(
          isLoading: true,
          error: null,
          currentTrack: event.track,
        ),
      );

      String? streamUrl;

      // PRIMERO: Verificar si la canción está descargada localmente
      final offlineService = await _getOfflineService();
      if (offlineService != null && offlineService.isInitialized) {
        final localPath = await offlineService.getLocalAudioPath(
          event.track.videoId,
        );

        if (localPath != null && localPath.isNotEmpty) {
          streamUrl = 'file://$localPath';
        }
      }

      // Los endpoints ya devuelven stream_url con include_stream_urls=true
      // PERO: algunos endpoints como recently-listened pueden no tenerla
      // Fallback: obtener URL bajo demanda si no la tiene
      if (streamUrl == null || streamUrl.isEmpty) {
        streamUrl = event.track.streamUrl;
      }

      // Si aún no hay streamUrl, usar el use case para obtenerla
      if (streamUrl == null || streamUrl.isEmpty) {
        streamUrl = await _getStreamUrlUseCase(event.track.videoId);
      }

      if (streamUrl == null || streamUrl.isEmpty) {
        emit(
          PlayerBlocLoaded(
            isLoading: false,
            error: 'No se pudo obtener la URL de streaming para esta canción.',
            currentTrack: event.track,
          ),
        );
        return;
      }

      await _loadTrackWithUrl(streamUrl, event.track, emit);
    } catch (e) {
      emit(
        PlayerBlocLoaded(
          isLoading: false,
          error: 'Error al cargar canción: $e',
          currentTrack: event.track,
        ),
      );
    }
  }

  Future<void> _loadTrackWithUrl(
    String streamUrl,
    NowPlayingData track,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      // Usar setAudioSource con MediaItem para notificaciones
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(streamUrl), tag: track.toMediaItem()),
      );

      // Esperar a que el audio esté listo (processingState ready)
      try {
        await _audioPlayer.processingStateStream
            .firstWhere((state) => state == ProcessingState.ready)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                return ProcessingState.ready;
              },
            );
      } catch (e) {
        // Timeout o error - continuamos
      }

      // IMPORTANTE: Esperar a que la duración esté disponible
      // El durationStream puede tardar en emitirse mientras se descargan los headers
      Duration actualDuration = _audioPlayer.duration ?? Duration.zero;
      if (actualDuration == Duration.zero) {
        try {
          final durationValue = await _audioPlayer.durationStream
              .firstWhere((d) => d != null && d.inSeconds > 0)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  // Usar la duración de los metadatos de la canción como fallback
                  return Duration(seconds: track.durationSeconds);
                },
              );
          actualDuration =
              durationValue ?? Duration(seconds: track.durationSeconds);
        } catch (e) {
          // Usar la duración de los metadatos como fallback
          actualDuration = Duration(seconds: track.durationSeconds);
        }
      }

      // ACTUALIZAR NOTIFICACIONES: Actualizar el mediaItem del handler para que muestre la canción en la notificación
      _updateHandlerMediaItem(track);

      emit(
        PlayerBlocLoaded(
          playlist: [track],
          isLoading: false,
          connectionState: AudioConnectionState.connected,
          currentIndex: 0,
          currentTrack: track,
          currentStreamUrl: streamUrl,
          duration: actualDuration,
          position: Duration.zero,
        ),
      );

      await _audioPlayer.play();
    } catch (e) {
      emit(
        PlayerBlocLoaded(
          playlist: [track],
          isLoading: false,
          error: 'Error al cargar audio: $e',
          connectionState: AudioConnectionState.disconnected,
          currentIndex: 0,
          currentTrack: track,
          currentStreamUrl: streamUrl,
          duration: Duration(seconds: track.durationSeconds),
        ),
      );
      rethrow;
    }
  }

  Future<void> _onLoadPlaylist(
    LoadPlaylistEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      emit(
        PlayerBlocLoaded(
          isLoading: true,
          error: null,
          playlist: event.playlist,
        ),
      );

      const Duration delayBetweenRequests = Duration(milliseconds: 800);

      final audioSources = <AudioSource>[];
      final totalTracks = event.playlist.length;

      for (int i = 0; i < totalTracks; i++) {
        final track = event.playlist[i];

        emit(
          PlayerBlocLoaded(
            isLoading: true,
            playlist: event.playlist,
            error: null,
          ),
        );

        final audioSource = await _loadTrackStreamWithRetry(track, 5);
        if (audioSource != null) {
          audioSources.add(audioSource);
        }

        if (i < totalTracks - 1) {
          await Future.delayed(delayBetweenRequests);
        }
      }

      if (audioSources.isEmpty) {
        emit(
          PlayerBlocLoaded(
            isLoading: false,
            error: 'No se pudieron cargar las URLs de streaming',
            playlist: event.playlist,
          ),
        );
        return;
      }

      final startIndex = event.startIndex ?? 0;
      final safeStartIndex = startIndex < audioSources.length ? startIndex : 0;

      await _audioPlayer.setAudioSources(
        audioSources,
        initialIndex: safeStartIndex,
      );

      // Esperar a que la duración esté disponible para la canción actual
      Duration actualDuration = _audioPlayer.duration ?? Duration.zero;
      if (actualDuration == Duration.zero) {
        final firstTrack = event.playlist[safeStartIndex];
        try {
          final durationValue = await _audioPlayer.durationStream
              .firstWhere((d) => d != null && d.inSeconds > 0)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  return Duration(seconds: firstTrack.durationSeconds);
                },
              );
          actualDuration =
              durationValue ?? Duration(seconds: firstTrack.durationSeconds);
        } catch (e) {
          actualDuration = Duration(seconds: firstTrack.durationSeconds);
        }
      }

      emit(
        PlayerBlocLoaded(
          playlist: event.playlist,
          isLoading: false,
          connectionState: AudioConnectionState.connected,
          currentIndex: safeStartIndex < event.playlist.length
              ? safeStartIndex
              : 0,
          currentTrack: safeStartIndex < event.playlist.length
              ? event.playlist[safeStartIndex]
              : null,
          duration: actualDuration,
          position: Duration.zero,
        ),
      );

      await _audioPlayer.play();
    } catch (e) {
      emit(
        PlayerBlocLoaded(
          isLoading: false,
          error: 'Error al cargar playlist: $e',
          playlist: event.playlist,
        ),
      );
    }
  }

  Future<AudioSource?> _loadTrackStreamWithRetry(
    NowPlayingData track,
    int maxRetries,
  ) async {
    String? streamUrl;

    // PRIMERO: Verificar si la canción está descargada localmente
    final offlineService = await _getOfflineService();
    if (offlineService != null && offlineService.isInitialized) {
      final localPath = await offlineService.getLocalAudioPath(track.videoId);

      if (localPath != null && localPath.isNotEmpty) {
        streamUrl = 'file://$localPath';
      }
    }

    // Los endpoints ya devuelven stream_url con include_stream_urls=true
    // No es necesario llamar a /music/stream/{videoId}
    if (streamUrl == null || streamUrl.isEmpty) {
      streamUrl = track.streamUrl;
    }

    if (streamUrl == null || streamUrl.isEmpty) {
      return null;
    }

    // Usar toMediaItem() para que las notificaciones muestren info correcta
    return AudioSource.uri(Uri.parse(streamUrl), tag: track.toMediaItem());
  }

  Future<void> _onPlayTrackAtIndex(
    PlayTrackAtIndexEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      if (state is PlayerBlocLoaded) {
        final currentState = state as PlayerBlocLoaded;
        if (event.index >= 0 && event.index < currentState.playlist.length) {
          final track = currentState.playlist[event.index];

          final streamUrl = track.streamUrl;

          if (streamUrl == null || streamUrl.isEmpty) {
            add(
              const AudioErrorEvent(
                'La canción no tiene URL de streaming. Asegúrate de usar include_stream_urls=true en el endpoint.',
              ),
            );
            return;
          }

          await _audioPlayer.seek(Duration.zero, index: event.index);
          await _audioPlayer.play();

          emit(
            currentState.copyWith(
              currentIndex: event.index,
              currentTrack: track,
              currentStreamUrl: streamUrl,
            ),
          );
        }
      }
    } catch (e) {
      add(
        AudioErrorEvent(
          'Error al reproducir canción en índice ${event.index}: $e',
        ),
      );
    }
  }

  Future<void> _onAddToPlaylist(
    AddToPlaylistEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      if (state is PlayerBlocLoaded) {
        final currentState = state as PlayerBlocLoaded;

        final streamUrl = event.track.streamUrl;

        if (streamUrl == null || streamUrl.isEmpty) {
          add(
            const AudioErrorEvent(
              'La canción no tiene URL de streaming. Asegúrate de usar include_stream_urls=true en el endpoint.',
            ),
          );
          return;
        }

        final newPlaylist = List<NowPlayingData>.from(currentState.playlist)
          ..add(event.track);

        await _audioPlayer.addAudioSource(
          AudioSource.uri(Uri.parse(streamUrl), tag: event.track.toMediaItem()),
        );

        emit(currentState.copyWith(playlist: newPlaylist));
      }
    } catch (e) {
      add(AudioErrorEvent('Error al agregar canción a playlist: $e'));
    }
  }

  Future<void> _onRemoveFromPlaylist(
    RemoveFromPlaylistEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      if (state is PlayerBlocLoaded) {
        final currentState = state as PlayerBlocLoaded;
        if (event.index >= 0 && event.index < currentState.playlist.length) {
          final newPlaylist = List<NowPlayingData>.from(currentState.playlist)
            ..removeAt(event.index);

          await _audioPlayer.removeAudioSourceAt(event.index);

          emit(currentState.copyWith(playlist: newPlaylist));
        }
      }
    } catch (e) {
      add(AudioErrorEvent('Error al remover canción de playlist: $e'));
    }
  }

  Future<void> _onSetVolume(
    SetVolumeEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      final clampedVolume = event.volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);

      if (state is PlayerBlocLoaded) {
        emit((state as PlayerBlocLoaded).copyWith(volume: clampedVolume));
      }
    } catch (e) {
      add(AudioErrorEvent('Error al cambiar volumen: $e'));
    }
  }

  Future<void> _onSetSpeed(
    SetSpeedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      final clampedSpeed = event.speed.clamp(0.5, 2.0);
      await _audioPlayer.setSpeed(clampedSpeed);

      if (state is PlayerBlocLoaded) {
        emit((state as PlayerBlocLoaded).copyWith(speed: clampedSpeed));
      }
    } catch (e) {
      add(AudioErrorEvent('Error al cambiar velocidad: $e'));
    }
  }

  Future<void> _onSetLoopMode(
    SetLoopModeEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      await _audioPlayer.setLoopMode(event.loopMode);

      if (state is PlayerBlocLoaded) {
        emit((state as PlayerBlocLoaded).copyWith(loopMode: event.loopMode));
      }
    } catch (e) {
      add(AudioErrorEvent('Error al cambiar modo de repetición: $e'));
    }
  }

  Future<void> _onToggleShuffle(
    ToggleShuffleEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      if (state is PlayerBlocLoaded) {
        final currentState = state as PlayerBlocLoaded;
        final newShuffleState = !currentState.isShuffleEnabled;

        await _audioPlayer.setShuffleModeEnabled(newShuffleState);

        emit(currentState.copyWith(isShuffleEnabled: newShuffleState));
      }
    } catch (e) {
      add(AudioErrorEvent('Error al cambiar modo shuffle: $e'));
    }
  }

  Future<void> _onAudioPlayerStateChanged(
    AudioPlayerStateChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    // Si el estado no es PlayerBlocLoaded, crear uno nuevo con los datos del player
    if (state is! PlayerBlocLoaded) {
      final playbackState = event.playerState.playing
          ? PlaybackState.playing
          : PlaybackState.paused;

      emit(
        PlayerBlocLoaded(
          playbackState: playbackState,
          processingState: event.playerState.processingState,
          connectionState: AudioConnectionState.connected,
        ),
      );
      return;
    }

    final currentState = state as PlayerBlocLoaded;
    final previousProcessingState = currentState.processingState;
    final playbackState = event.playerState.playing
        ? PlaybackState.playing
        : PlaybackState.paused;

    emit(
      currentState.copyWith(
        playbackState: playbackState,
        processingState: event.playerState.processingState,
      ),
    );

    // Auto-play: cuando termina una canción, reproducir la siguiente automáticamente
    // Solo si:
    // 1. La canción actual terminó (processingState changed to completed)
    // 2. No es el modo loop.one (repetir una)
    // 3. Auto-play está habilitado en settings
    if (previousProcessingState != ProcessingState.completed &&
        event.playerState.processingState == ProcessingState.completed) {
      await _handleAutoPlay();
    }
  }

  /// Maneja la reproducción automática de la siguiente canción
  Future<void> _handleAutoPlay() async {
    try {
      // Verificar si auto-play está habilitado
      final profileCubit = GetIt.I<ProfileCubit>();
      final autoPlayEnabled = profileCubit.state.settings?.autoPlay ?? true;

      if (!autoPlayEnabled) {
        return;
      }

      // Verificar el modo de repetición actual
      if (state is PlayerBlocLoaded) {
        final currentState = state as PlayerBlocLoaded;

        // Si está en modo loop.one, no necesitamos avanzar automáticamente
        if (currentState.loopMode == LoopMode.one) {
          return;
        }

        // Verificar si hay siguiente canción
        if (currentState.canPlayNext) {
          add(const NextTrackEvent());
        } else if (currentState.loopMode == LoopMode.all &&
            currentState.playlist.isNotEmpty) {
          // Si está en modo loop all y es la última canción, volver al inicio
          add(const PlayTrackAtIndexEvent(0));
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _onPositionChanged(
    PositionChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    if (state is PlayerBlocLoaded) {
      emit((state as PlayerBlocLoaded).copyWith(position: event.position));

      // Actualizar historial cada ~5 segundos (fire and forget)
      unawaited(_saveHistoryPlayedDuration(event.position.inSeconds));
    } else {
      // Crear estado si no existe
      emit(PlayerBlocLoaded(position: event.position));
    }
  }

  Future<void> _onDurationChanged(
    DurationChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    if (state is PlayerBlocLoaded) {
      emit((state as PlayerBlocLoaded).copyWith(duration: event.duration));
    } else {
      // Crear estado si no existe
      emit(PlayerBlocLoaded(duration: event.duration));
    }
  }

  Future<void> _onBufferedPositionChanged(
    BufferedPositionChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    if (state is PlayerBlocLoaded) {
      emit(
        (state as PlayerBlocLoaded).copyWith(
          bufferedPosition: event.bufferedPosition,
        ),
      );
    }
  }

  Future<void> _onCurrentIndexChanged(
    CurrentIndexChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    if (state is PlayerBlocLoaded) {
      final currentState = state as PlayerBlocLoaded;
      final currentTrack =
          event.index != null && event.index! < currentState.playlist.length
          ? currentState.playlist[event.index!]
          : null;

      // Si cambió el track, crear nueva entrada de historial (fire and forget)
      if (currentTrack != null && event.index != currentState.currentIndex) {
        unawaited(_startNewHistoryEntry(currentTrack));
      }

      emit(
        currentState.copyWith(
          currentIndex: event.index,
          currentTrack: currentTrack,
        ),
      );
    } else if (event.index != null) {
      // Crear estado básico si no existe
      emit(PlayerBlocLoaded(currentIndex: event.index));
    }
  }

  Future<void> _onAudioError(
    AudioErrorEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    if (state is PlayerBlocLoaded) {
      emit(
        (state as PlayerBlocLoaded).copyWith(
          error: event.error,
          processingState: ProcessingState.idle,
        ),
      );
    } else {
      emit(
        PlayerBlocLoaded(
          error: event.error,
          processingState: ProcessingState.idle,
        ),
      );
    }
  }

  Future<void> _onInitializeAudioService(
    InitializeAudioServiceEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      // Intentar obtener el AudioPlayerHandler
      if (GetIt.I.isRegistered<AudioPlayerHandler>()) {
        final handler = GetIt.I<AudioPlayerHandler>();
        _audioPlayerInstance = handler.player;
        _initializePlayer();
      } else {
        // Reintentar después de un delay
        await Future.delayed(const Duration(seconds: 2));
        if (GetIt.I.isRegistered<AudioPlayerHandler>()) {
          final handler = GetIt.I<AudioPlayerHandler>();
          _audioPlayerInstance = handler.player;
          _initializePlayer();
        } else {
          // FALLBACK: Crear AudioPlayer básico SI NO se ha creado antes
          // Esto asegura que los streams se inicialicen
          if (_audioPlayerInstance == null) {
            _audioPlayerInstance = AudioPlayer();
            _initializePlayer();
          }
        }
      }

      if (state is PlayerBlocLoaded) {
        emit(
          (state as PlayerBlocLoaded).copyWith(
            connectionState: AudioConnectionState.connected,
          ),
        );
      } else {
        emit(
          const PlayerBlocLoaded(
            connectionState: AudioConnectionState.connected,
          ),
        );
      }
    } catch (e) {
      add(AudioErrorEvent('Error initializing audio handler: $e'));
    }
  }

  Future<void> _onDisposeAudioService(
    DisposeAudioServiceEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      if (state is PlayerBlocLoaded) {
        emit(
          (state as PlayerBlocLoaded).copyWith(
            connectionState: AudioConnectionState.disconnected,
          ),
        );
      }
    } catch (e) {
      add(AudioErrorEvent('Error al cerrar audio service: $e'));
    }
  }

  @override
  Future<void> close() async {
    // Finalizar entrada de historial antes de dispose
    await _finalizeCurrentHistoryEntry();

    await _playerStateSubscription.cancel();
    await _positionSubscription.cancel();
    await _durationSubscription.cancel();
    await _bufferedPositionSubscription.cancel();
    await _currentIndexSubscription.cancel();
    await _audioPlayer.dispose();
    return super.close();
  }
}
