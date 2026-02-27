import 'dart:async';

import 'package:audio_service/audio_service.dart' show AudioHandler;
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/main.dart';

part 'player_bloc_event.dart';
part 'player_bloc_state.dart';

class PlayerBlocBloc extends Bloc<PlayerBlocEvent, PlayerBlocState> {
  final ApiServices _apiServices;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late StreamSubscription _playerStateSubscription;
  late StreamSubscription _positionSubscription;
  late StreamSubscription _durationSubscription;
  late StreamSubscription _bufferedPositionSubscription;
  late StreamSubscription _currentIndexSubscription;

  AudioHandler? _audioHandler;

  PlayerBlocBloc(this._apiServices) : super(const PlayerBlocInitial()) {
    _initializePlayer();
    _registerEventHandlers();
  }

  void _initializePlayer() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      (playerState) => add(AudioPlayerStateChangedEvent(playerState)),
    );

    _positionSubscription = _audioPlayer.positionStream.listen(
      (position) => add(PositionChangedEvent(position)),
    );

    _durationSubscription = _audioPlayer.durationStream.listen(
      (duration) => add(DurationChangedEvent(duration ?? Duration.zero)),
    );

    _bufferedPositionSubscription = _audioPlayer.bufferedPositionStream.listen(
      (bufferedPosition) => add(BufferedPositionChangedEvent(bufferedPosition)),
    );

    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen(
      (index) => add(CurrentIndexChangedEvent(index)),
    );
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
      _audioHandler?.play();
    } catch (e) {
      add(AudioErrorEvent('Error al reproducir: $e'));
    }
  }

  Future<void> _onPause(PauseEvent event, Emitter<PlayerBlocState> emit) async {
    try {
      await _audioPlayer.pause();
      _audioHandler?.pause();
    } catch (e) {
      add(AudioErrorEvent('Error al pausar: $e'));
    }
  }

  Future<void> _onStop(StopEvent event, Emitter<PlayerBlocState> emit) async {
    try {
      await _audioPlayer.stop();
      _audioHandler?.stop();
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
          _audioHandler?.skipToNext();
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
          _audioHandler?.skipToPrevious();
        }
      }
    } catch (e) {
      add(AudioErrorEvent('Error al cambiar a anterior: $e'));
    }
  }

  Future<void> _onSeek(SeekEvent event, Emitter<PlayerBlocState> emit) async {
    try {
      await _audioPlayer.seek(event.position);
      _audioHandler?.seek(event.position);
    } catch (e) {
      add(AudioErrorEvent('Error al hacer seek: $e'));
    }
  }

  Future<void> _onLoadTrack(
    LoadTrackEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      emit(
        PlayerBlocLoaded(
          isLoading: true,
          error: null,
          currentTrack: event.track,
        ),
      );

      // Siempre obtener una URL fresca del backend para evitar 403
      final freshStreamUrl = await _fetchFreshStreamUrl(event.track.videoId);
      final streamUrl = freshStreamUrl ?? event.track.streamUrl;

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
      await _audioPlayer.setUrl(streamUrl);

      try {
        await _audioPlayer.processingStateStream
            .firstWhere((state) => state == ProcessingState.ready)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                debugPrint(
                  '_loadTrackWithUrl: Timeout esperando audio ready, continuando...',
                );
                return ProcessingState.ready;
              },
            );
      } catch (e) {
        debugPrint('_loadTrackWithUrl: Error esperando processingState: $e');
      }

      emit(
        PlayerBlocLoaded(
          playlist: [track],
          isLoading: false,
          connectionState: AudioConnectionState.connected,
          currentIndex: 0,
          currentTrack: track,
          currentStreamUrl: streamUrl,
        ),
      );

      await _audioPlayer.play();
    } catch (e) {
      debugPrint('_loadTrackWithUrl: Error cargando audio: $e');

      emit(
        PlayerBlocLoaded(
          playlist: [track],
          isLoading: false,
          error: 'Error al cargar audio: $e',
          connectionState: AudioConnectionState.disconnected,
          currentIndex: 0,
          currentTrack: track,
          currentStreamUrl: streamUrl,
        ),
      );
      rethrow;
    }
  }

  /// Obtiene una URL de streaming fresca del backend.
  /// Las URLs de YouTube expiran y están vinculadas a la IP del servidor,
  /// por lo que necesitamos obtener una URL fresca cada vez que reproducimos.
  /// 
  /// Usa el endpoint de proxy (/music/stream-proxy/:videoId) que reenvía
  /// el audio desde el servidor, evitando el problema de IP restriction.
  /// El token se pasa como query parameter para validación.
  Future<String?> _fetchFreshStreamUrl(String videoId) async {
    try {
      // Obtener el token de acceso
      final authManager = await getIt.getAsync<AuthManager>();
      final accessToken = await authManager.getCurrentAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('PlayerBloc: No access token available');
        return null;
      }
      
      // Obtener la URL del proxy desde el backend
      // El endpoint /music/stream devuelve JSON con proxyUrl
      final response = await _apiServices.get('/music/stream/$videoId');
      final data = response is Response ? response.data : response;
      if (data is Map<String, dynamic>) {
        // Obtener proxyUrl base y añadir el token como query parameter
        String? proxyUrl = data['proxyUrl'] as String?;
        if (proxyUrl != null && proxyUrl.isNotEmpty) {
          // Añadir token como query parameter para autenticación
          final separator = proxyUrl.contains('?') ? '&' : '?';
          proxyUrl = '$proxyUrl${separator}token=$accessToken';
          debugPrint('PlayerBloc: Using proxy URL with token for $videoId');
          return proxyUrl;
        }
        // Fallback a streamUrl si no hay proxyUrl
        return data['streamUrl'] as String?;
      }
    } catch (e) {
      debugPrint(
        'PlayerBloc: Error getting proxy stream URL for $videoId: $e',
      );
    }
    return null;
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
    // Obtener URL fresca del backend
    final freshStreamUrl = await _fetchFreshStreamUrl(track.videoId);
    final streamUrl = freshStreamUrl ?? track.streamUrl;

    if (streamUrl == null || streamUrl.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'Error: No se pudo obtener stream URL para ${track.videoId}.',
        );
      }
      return null;
    }

    return AudioSource.uri(Uri.parse(streamUrl), tag: track);
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
              AudioErrorEvent(
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

          _audioHandler?.skipToQueueItem(event.index);
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
            AudioErrorEvent(
              'La canción no tiene URL de streaming. Asegúrate de usar include_stream_urls=true en el endpoint.',
            ),
          );
          return;
        }

        final newPlaylist = List<NowPlayingData>.from(currentState.playlist)
          ..add(event.track);

        await _audioPlayer.addAudioSource(
          AudioSource.uri(Uri.parse(streamUrl), tag: event.track),
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
    if (state is! PlayerBlocLoaded) return;

    final currentState = state as PlayerBlocLoaded;
    final playbackState = event.playerState.playing
        ? PlaybackState.playing
        : PlaybackState.paused;

    emit(
      currentState.copyWith(
        playbackState: playbackState,
        processingState: event.playerState.processingState,
      ),
    );
  }

  Future<void> _onPositionChanged(
    PositionChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    if (state is PlayerBlocLoaded) {
      emit((state as PlayerBlocLoaded).copyWith(position: event.position));
    }
  }

  Future<void> _onDurationChanged(
    DurationChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    if (state is PlayerBlocLoaded) {
      emit((state as PlayerBlocLoaded).copyWith(duration: event.duration));
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

      emit(
        currentState.copyWith(
          currentIndex: event.index,
          currentTrack: currentTrack,
        ),
      );
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
    if (state is PlayerBlocLoaded) {
      emit(
        (state as PlayerBlocLoaded).copyWith(
          connectionState: AudioConnectionState.connected,
        ),
      );
    } else {
      emit(
        const PlayerBlocLoaded(connectionState: AudioConnectionState.connected),
      );
    }
  }

  Future<void> _onDisposeAudioService(
    DisposeAudioServiceEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      _audioHandler = null;
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
    await _playerStateSubscription.cancel();
    await _positionSubscription.cancel();
    await _durationSubscription.cancel();
    await _bufferedPositionSubscription.cancel();
    await _currentIndexSubscription.cancel();
    await _audioPlayer.dispose();
    return super.close();
  }
}
