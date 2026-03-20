// ignore_for_file: unawaited_futures, deprecated_member_use
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/services/audio_handler_service.dart';
import 'package:music_app/data/offline/models/offline_history.dart';
import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/domain/player_engine.dart';
import 'package:music_app/features/player/infrastructure/just_audio_player_engine.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/features/recently_played/domain/usecases/record_listen_usecase.dart';

part 'player_bloc_event.dart';
part 'player_bloc_state.dart';

class PlayerBlocBloc extends Bloc<PlayerBlocEvent, PlayerBlocState> {
  PlayerEngine? _engine;
  bool _isEngineInitialized = false;
  final PlayerEngine? _engineOverride;

  PlayerEngine get _playerEngine {
    if (_engineOverride != null) return _engineOverride;
    if (_engine != null) return _engine!;

    // Obtener el AudioPlayer del handler
    final handler = GetIt.I<AudioPlayerHandler>();
    _engine = JustAudioPlayerEngine(handler.player);
    return _engine!;
  }

  PlayerBlocBloc({PlayerEngine? engine})
    : _engineOverride = engine,
      super(PlayerBlocState.initial()) {
    _registerEventHandlers();

    // Si hay engine override (tests), inicializar inmediatamente
    if (_engineOverride != null) {
      _initializeEngine();
    }
  }

  // Prevenir cargas duplicadas del mismo track
  String? _lastLoadedVideoId;
  String? _lastLoadedSourceId;
  bool _isLoading = false;

  OfflineService? _offlineService;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _bufferedPositionSubscription;
  StreamSubscription? _currentIndexSubscription;

  Future<OfflineService?> _getOfflineService() async {
    if (_offlineService != null) return _offlineService;

    try {
      if (GetIt.I.isRegistered<OfflineService>()) {
        _offlineService = await GetIt.I.getAsync<OfflineService>();
        return _offlineService;
      }
    } catch (e) {
      debugPrint('PlayerBloc: OfflineService not available: $e');
    }
    return null;
  }

  void _initializeEngine() {
    if (_isEngineInitialized) return;

    final engine = _engineOverride ?? _playerEngine;

    _playerStateSubscription = engine.playerStateStream.listen(
      (playerState) => add(AudioPlayerStateChangedEvent(playerState)),
    );

    _positionSubscription = engine.positionStream.listen(
      (position) => add(PositionChangedEvent(position)),
    );

    _durationSubscription = engine.durationStream.listen(
      (duration) => add(DurationChangedEvent(duration ?? Duration.zero)),
    );

    _bufferedPositionSubscription = engine.bufferedPositionStream.listen(
      (bufferedPosition) => add(BufferedPositionChangedEvent(bufferedPosition)),
    );

    _currentIndexSubscription = engine.currentIndexStream.listen(
      (index) => add(CurrentIndexChangedEvent(index)),
    );

    _isEngineInitialized = true;
  }

  void _ensureEngineInitialized() {
    if (!_isEngineInitialized) {
      _initializeEngine();
    }
  }

  void _registerEventHandlers() {
    on<PlayEvent>(_onPlay);
    on<PauseEvent>(_onPause);
    on<StopEvent>(_onStop);
    on<PlayPauseToggleEvent>(_onPlayPauseToggle);

    on<NextTrackEvent>(_onNextTrack);
    on<PreviousTrackEvent>(_onPreviousTrack);
    on<SeekEvent>(_onSeek);

    on<PlayRequestEvent>(_onPlayRequest);
    on<LoadTrackEvent>(_onLoadTrack);
    on<LoadPlaylistEvent>(_onLoadPlaylist);
    on<PlayTrackAtIndexEvent>(_onPlayTrackAtIndex);
    on<AddToPlaylistEvent>(_onAddToPlaylist);
    on<AddMultipleToPlaylistEvent>(_onAddMultipleToPlaylist);
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
    on<ResetPlayerEvent>(_onResetPlayer);
  }

  Future<void> _onPlay(PlayEvent event, Emitter<PlayerBlocState> emit) async {
    try {
      _ensureEngineInitialized();
      await _playerEngine.play();
    } catch (e) {
      emit(state.copyWith(error: 'Error al reproducir: $e'));
    }
  }

  Future<void> _onPause(PauseEvent event, Emitter<PlayerBlocState> emit) async {
    try {
      _ensureEngineInitialized();
      await _playerEngine.pause();
    } catch (e) {
      emit(state.copyWith(error: 'Error al pausar: $e'));
    }
  }

  Future<void> _onStop(StopEvent event, Emitter<PlayerBlocState> emit) async {
    try {
      _ensureEngineInitialized();
      await _playerEngine.stop();
      await _finalizeCurrentHistoryEntry();
      emit(state.copyWith(position: Duration.zero));
    } catch (e) {
      emit(state.copyWith(error: 'Error al detener: $e'));
    }
  }

  Future<void> _onPlayPauseToggle(
    PlayPauseToggleEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    if (state.isPlaying) {
      add(const PauseEvent());
    } else {
      add(const PlayEvent());
    }
  }

  Future<void> _onNextTrack(
    NextTrackEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      _ensureEngineInitialized();
      if (state.canPlayNext) {
        await _playerEngine.seekToNext();
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error al cambiar a siguiente: $e'));
    }
  }

  Future<void> _onPreviousTrack(
    PreviousTrackEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      _ensureEngineInitialized();
      if (state.canPlayPrevious) {
        await _playerEngine.seekToPrevious();
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error al cambiar a anterior: $e'));
    }
  }

  Future<void> _onSeek(SeekEvent event, Emitter<PlayerBlocState> emit) async {
    try {
      _ensureEngineInitialized();
      await _playerEngine.seek(event.position);
    } catch (e) {
      emit(state.copyWith(error: 'Error al hacer seek: $e'));
    }
  }

  Future<void> _onPlayRequest(
    PlayRequestEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    final currentVideoId = state.currentTrack?.videoId;
    final targetVideoId = event.track.videoId;

    // Si es la misma canción, retomar si está pausada
    if (currentVideoId == targetVideoId) {
      if (!state.isPlaying) {
        add(const PlayEvent());
      }
      return;
    }

    // Si playAsSingle, cargar como canción individual
    if (event.playAsSingle) {
      await _handleLoadTrack(
        event.track,
        'single:${event.track.videoId}',
        emit,
      );
      return;
    }

    // Verificar si la canción ya está en la playlist
    if (state.playlist.isNotEmpty) {
      final trackIndex = state.playlist.indexWhere(
        (t) => t.videoId == targetVideoId,
      );

      if (trackIndex >= 0) {
        await _handlePlayTrackAtIndex(trackIndex, emit);
        return;
      }
    }

    // No está en playlist, cargar como individual
    await _handleLoadTrack(event.track, null, emit);
  }

  Future<void> _onLoadTrack(
    LoadTrackEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    await _handleLoadTrack(event.track, event.sourceId, emit);
  }

  Future<void> _handleLoadTrack(
    NowPlayingData track,
    String? sourceId,
    Emitter<PlayerBlocState> emit,
  ) async {
    debugPrint('PlayerBloc: Loading track ${track.videoId} - ${track.title}');

    // Prevenir cargas duplicadas del mismo track con el mismo sourceId
    if (_isLoading &&
        _lastLoadedVideoId == track.videoId &&
        _lastLoadedSourceId == sourceId) {
      debugPrint(
        'PlayerBloc: Ignoring duplicate load request for ${track.videoId}',
      );
      return;
    }

    _isLoading = true;
    _lastLoadedVideoId = track.videoId;
    _lastLoadedSourceId = sourceId;

    try {
      // Verificar URL
      String? streamUrl = track.streamUrl;

      // Verificar si hay versión offline
      final offlineService = await _getOfflineService();
      if (offlineService != null && offlineService.isInitialized) {
        final localPath = await offlineService.getLocalAudioPath(track.videoId);
        if (localPath != null && localPath.isNotEmpty) {
          streamUrl = 'file://$localPath';
        }
      }

      if (streamUrl == null || streamUrl.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'No se pudo obtener la URL de streaming',
          ),
        );
        return;
      }

      // Emitir estado de carga
      emit(
        state.copyWith(
          isLoading: true,
          error: null,
          currentTrack: track,
          currentIndex: 0,
          playlist: [track],
          sourceId: sourceId,
        ),
      );

      // Preparar audio source
      final parsedUri = Uri.parse(streamUrl);
      final audioSource = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: [AudioSource.uri(parsedUri, tag: track.toMediaItem())],
      );

      // Cargar en el engine
      await _playerEngine.setAudioSource(audioSource, preload: false);

      // Actualizar notificación
      _updateHandlerMediaItem(track);

      // Iniciar reproducción
      final actualDuration = Duration(
        seconds: track.durationSeconds > 0 ? track.durationSeconds : 0,
      );

      emit(
        state.copyWith(
          playbackState: PlaybackState.playing,
          processingState: ProcessingState.ready,
          connectionState: AudioConnectionState.connected,
          currentTrack: track,
          currentStreamUrl: streamUrl,
          currentIndex: 0,
          duration: actualDuration,
          position: Duration.zero,
          isLoading: false,
          error: null,
        ),
      );

      await _playerEngine.play();
      _recordListenToServer(track.videoId);
    } catch (e) {
      debugPrint('PlayerBloc: Error loading track: $e');
      emit(
        state.copyWith(isLoading: false, error: 'Error al cargar canción: $e'),
      );
    } finally {
      if (_lastLoadedVideoId == track.videoId &&
          _lastLoadedSourceId == sourceId) {
        _isLoading = false;
        _lastLoadedVideoId = null;
        _lastLoadedSourceId = null;
      }
    }
  }

  Future<void> _handlePlayTrackAtIndex(
    int index,
    Emitter<PlayerBlocState> emit,
  ) async {
    if (index < 0 || index >= state.playlist.length) return;

    final track = state.playlist[index];
    final streamUrl = track.streamUrl;

    if (streamUrl == null || streamUrl.isEmpty) {
      emit(state.copyWith(error: 'La canción no tiene URL de streaming'));
      return;
    }

    // Si ya es la canción actual, solo retomar si está pausada
    if (state.currentIndex == index &&
        state.currentTrack?.videoId == track.videoId) {
      if (!state.isPlaying) {
        await _playerEngine.play();
        emit(state.copyWith(playbackState: PlaybackState.playing));
      }
      return;
    }

    // Seek al nuevo índice
    await _playerEngine.seek(Duration.zero, index: index);
    await _playerEngine.play();
    _updateHandlerMediaItem(track);

    emit(
      state.copyWith(
        playbackState: PlaybackState.playing,
        currentIndex: index,
        currentTrack: track,
        currentStreamUrl: streamUrl,
      ),
    );
  }

  Future<void> _onLoadPlaylist(
    LoadPlaylistEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();

    try {
      if (event.playlist.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'La playlist está vacía'));
        return;
      }

      final startIndex = (event.startIndex ?? 0).clamp(
        0,
        event.playlist.length - 1,
      );

      // Emitir estado de carga
      emit(state.copyWith(isLoading: true, error: null));

      // Crear audio sources
      final audioSources = <AudioSource>[];
      for (final track in event.playlist) {
        if (track.streamUrl != null && track.streamUrl!.isNotEmpty) {
          try {
            final parsedUri = Uri.parse(track.streamUrl!);
            audioSources.add(
              AudioSource.uri(parsedUri, tag: track.toMediaItem()),
            );
          } catch (e) {
            debugPrint(
              'PlayerBloc: Error parsing URL for ${track.videoId}: $e',
            );
          }
        }
      }

      if (audioSources.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'No se pudieron cargar las URLs de streaming',
          ),
        );
        return;
      }

      // Crear concatenating source
      final concatenatingSource = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: audioSources,
      );

      // Cargar en el engine
      await _playerEngine.setAudioSource(concatenatingSource, preload: false);
      await _playerEngine.setLoopMode(LoopMode.all);

      final firstTrack = event.playlist[startIndex];
      final actualDuration = Duration(
        seconds: firstTrack.durationSeconds > 0
            ? firstTrack.durationSeconds
            : 0,
      );

      _updateHandlerMediaItem(firstTrack);

      emit(
        state.copyWith(
          playbackState: PlaybackState.playing,
          playlist: event.playlist,
          isLoading: false,
          connectionState: AudioConnectionState.connected,
          currentIndex: startIndex,
          currentTrack: firstTrack,
          currentStreamUrl: firstTrack.streamUrl,
          duration: actualDuration,
          position: Duration.zero,
          sourceId: event.sourceId,
          error: null,
        ),
      );

      // Seek al índice de inicio y reproducir
      await _playerEngine.seek(Duration.zero, index: startIndex);
      await _playerEngine.play();
      _recordListenToServer(firstTrack.videoId);
    } catch (e) {
      debugPrint('PlayerBloc: Error loading playlist: $e');
      emit(
        state.copyWith(isLoading: false, error: 'Error al cargar playlist: $e'),
      );
    }
  }

  Future<void> _onPlayTrackAtIndex(
    PlayTrackAtIndexEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    await _handlePlayTrackAtIndex(event.index, emit);
  }

  Future<void> _onAddToPlaylist(
    AddToPlaylistEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();

    try {
      final streamUrl = event.track.streamUrl;

      if (streamUrl == null || streamUrl.isEmpty) {
        emit(state.copyWith(error: 'La canción no tiene URL de streaming'));
        return;
      }

      // Verificar si ya existe
      final exists = state.playlist.any(
        (t) => t.videoId == event.track.videoId,
      );
      if (exists) {
        debugPrint('PlayerBloc: Track already in playlist');
        return;
      }

      final newPlaylist = List<NowPlayingData>.from(state.playlist)
        ..add(event.track);
      final parsedUri = Uri.parse(streamUrl);

      await _playerEngine.addAudioSources([
        AudioSource.uri(parsedUri, tag: event.track.toMediaItem()),
      ]);

      emit(state.copyWith(playlist: newPlaylist));
    } catch (e) {
      emit(state.copyWith(error: 'Error al agregar canción a playlist: $e'));
    }
  }

  Future<void> _onAddMultipleToPlaylist(
    AddMultipleToPlaylistEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();

    try {
      final existingVideoIds = state.playlist.map((t) => t.videoId).toSet();
      final validTracks = event.tracks
          .where(
            (track) =>
                track.streamUrl != null &&
                track.streamUrl!.isNotEmpty &&
                !existingVideoIds.contains(track.videoId),
          )
          .toList();

      if (validTracks.isEmpty) {
        debugPrint('PlayerBloc: No valid tracks to add');
        return;
      }

      final newSources = validTracks.map((track) {
        final parsedUri = Uri.parse(track.streamUrl!);
        return AudioSource.uri(parsedUri, tag: track.toMediaItem());
      }).toList();

      await _playerEngine.addAudioSources(newSources);

      final newPlaylist = List<NowPlayingData>.from(state.playlist)
        ..addAll(validTracks);
      emit(state.copyWith(playlist: newPlaylist));
    } catch (e) {
      emit(state.copyWith(error: 'Error al agregar canciones: $e'));
    }
  }

  Future<void> _onRemoveFromPlaylist(
    RemoveFromPlaylistEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();

    try {
      if (event.index < 0 || event.index >= state.playlist.length) return;

      final removedTrack = state.playlist[event.index];
      final wasCurrentTrack =
          state.currentTrack?.videoId == removedTrack.videoId;

      final newPlaylist = List<NowPlayingData>.from(state.playlist)
        ..removeAt(event.index);

      await _playerEngine.removeAudioSourceAt(event.index);

      if (wasCurrentTrack) {
        if (newPlaylist.isEmpty) {
          await _playerEngine.stop();
          emit(
            state.copyWith(
              playlist: [],
              clearCurrentIndex: true,
              clearCurrentTrack: true,
              currentStreamUrl: null,
              playbackState: PlaybackState.stopped,
              processingState: ProcessingState.idle,
              position: Duration.zero,
            ),
          );
          return;
        }

        final safeIndex = (event.index >= newPlaylist.length)
            ? newPlaylist.length - 1
            : event.index;
        final nextTrack = newPlaylist[safeIndex];

        await _playerEngine.seek(Duration.zero, index: safeIndex);

        emit(
          state.copyWith(
            playlist: newPlaylist,
            currentIndex: safeIndex,
            currentTrack: nextTrack,
            currentStreamUrl: nextTrack.streamUrl,
          ),
        );
        return;
      }

      emit(state.copyWith(playlist: newPlaylist));
    } catch (e) {
      emit(state.copyWith(error: 'Error al remover canción: $e'));
    }
  }

  Future<void> _onSetVolume(
    SetVolumeEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      _ensureEngineInitialized();
      final clampedVolume = event.volume.clamp(0.0, 1.0);
      await _playerEngine.setVolume(clampedVolume);
      emit(state.copyWith(volume: clampedVolume));
    } catch (e) {
      emit(state.copyWith(error: 'Error al cambiar volumen: $e'));
    }
  }

  Future<void> _onSetSpeed(
    SetSpeedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      _ensureEngineInitialized();
      final clampedSpeed = event.speed.clamp(0.5, 2.0);
      await _playerEngine.setSpeed(clampedSpeed);
      emit(state.copyWith(speed: clampedSpeed));
    } catch (e) {
      emit(state.copyWith(error: 'Error al cambiar velocidad: $e'));
    }
  }

  Future<void> _onSetLoopMode(
    SetLoopModeEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      _ensureEngineInitialized();
      await _playerEngine.setLoopMode(event.loopMode);
      emit(state.copyWith(loopMode: event.loopMode));
    } catch (e) {
      emit(state.copyWith(error: 'Error al cambiar modo de repetición: $e'));
    }
  }

  Future<void> _onToggleShuffle(
    ToggleShuffleEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      _ensureEngineInitialized();
      final newState = !state.isShuffleEnabled;
      await _playerEngine.setShuffleModeEnabled(newState);
      emit(state.copyWith(isShuffleEnabled: newState));
    } catch (e) {
      emit(state.copyWith(error: 'Error al cambiar modo shuffle: $e'));
    }
  }

  Future<void> _onAudioPlayerStateChanged(
    AudioPlayerStateChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    final currentState = state;
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

    // Auto-play: cuando termina una canción, reproducir la siguiente
    if (previousProcessingState != ProcessingState.completed &&
        event.playerState.processingState == ProcessingState.completed) {
      await _handleAutoPlay();
    }
  }

  Future<void> _handleAutoPlay() async {
    try {
      final profileCubit = GetIt.I<ProfileCubit>();
      final autoPlayEnabled = profileCubit.state.settings?.autoPlay ?? true;

      if (!autoPlayEnabled) return;

      final currentState = state;

      if (currentState.loopMode == LoopMode.one) return;

      if (currentState.canPlayNext) {
        add(const NextTrackEvent());
      } else if (currentState.loopMode == LoopMode.all &&
          currentState.playlist.isNotEmpty) {
        add(const PlayTrackAtIndexEvent(0));
      }
    } catch (e) {
      debugPrint('PlayerBloc: Auto-play error: $e');
    }
  }

  Future<void> _onPositionChanged(
    PositionChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    emit(state.copyWith(position: event.position));
    unawaited(_saveHistoryPlayedDuration(event.position.inSeconds));
  }

  Future<void> _onDurationChanged(
    DurationChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    emit(state.copyWith(duration: event.duration));
  }

  Future<void> _onBufferedPositionChanged(
    BufferedPositionChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    emit(state.copyWith(bufferedPosition: event.bufferedPosition));
  }

  Future<void> _onCurrentIndexChanged(
    CurrentIndexChangedEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    final currentState = state;
    final currentTrack =
        event.index != null && event.index! < currentState.playlist.length
        ? currentState.playlist[event.index!]
        : null;

    if (currentTrack != null && event.index != currentState.currentIndex) {
      _updateHandlerMediaItem(currentTrack);
      unawaited(_startNewHistoryEntry(currentTrack));
      _recordListenToServer(currentTrack.videoId);
    }

    emit(
      currentState.copyWith(
        currentIndex: event.index,
        currentTrack: currentTrack,
      ),
    );
  }

  Future<void> _onAudioError(
    AudioErrorEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    emit(
      state.copyWith(error: event.error, processingState: ProcessingState.idle),
    );
  }

  Future<void> _onInitializeAudioService(
    InitializeAudioServiceEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    emit(state.copyWith(connectionState: AudioConnectionState.connected));
  }

  Future<void> _onDisposeAudioService(
    DisposeAudioServiceEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    emit(state.copyWith(connectionState: AudioConnectionState.disconnected));
  }

  Future<void> _onResetPlayer(
    ResetPlayerEvent event,
    Emitter<PlayerBlocState> emit,
  ) async {
    try {
      await _playerEngine.stop();
      await _playerEngine.setAudioSource(
        ConcatenatingAudioSource(children: []),
      );
      await _finalizeCurrentHistoryEntry();
      emit(PlayerBlocState.initial());
    } catch (e) {
      emit(state.copyWith(error: 'Error al resetear player: $e'));
    }
  }

  // ========== Historial de reproducción ==========

  String? _currentHistoryId;
  int _lastSavedPositionSeconds = 0;
  static const int _historyUpdateIntervalSeconds = 5;

  Future<void> _saveHistoryPlayedDuration(int positionSeconds) async {
    if (_currentHistoryId == null) return;

    if (positionSeconds - _lastSavedPositionSeconds <
        _historyUpdateIntervalSeconds) {
      return;
    }

    _lastSavedPositionSeconds = positionSeconds;

    try {
      final offlineService = await _getOfflineService();
      if (offlineService != null && offlineService.isInitialized) {
        await offlineService.updateHistoryPlayedDuration(
          _currentHistoryId!,
          positionSeconds,
        );
      }
    } catch (e) {
      debugPrint('PlayerBloc: History save error: $e');
    }
  }

  Future<void> _startNewHistoryEntry(NowPlayingData track) async {
    await _finalizeCurrentHistoryEntry();

    try {
      final offlineService = await _getOfflineService();
      if (offlineService == null || !offlineService.isInitialized) return;

      final artistName = track.artists.isNotEmpty
          ? track.artists.map((a) => a.name).join(', ')
          : 'Unknown Artist';

      String? thumbnailUrl;
      if (track.thumbnail != null) {
        thumbnailUrl = track.thumbnail?.url;
      } else if (track.thumbnails.isNotEmpty) {
        thumbnailUrl = track.thumbnails.last.url;
      }

      final history = OfflineHistory.create(
        songId: track.videoId,
        videoId: track.videoId,
        title: track.title,
        artist: artistName,
        thumbnail: thumbnailUrl,
        duration: track.durationSeconds,
        playedAt: DateTime.now(),
      );

      await offlineService.addToHistory(history);
      _currentHistoryId = history.historyId;
      _lastSavedPositionSeconds = 0;
    } catch (e) {
      debugPrint('PlayerBloc: History entry error: $e');
    }
  }

  Future<void> _finalizeCurrentHistoryEntry() async {
    if (_currentHistoryId == null) return;

    try {
      await _saveHistoryPlayedDurationInternal(
        _currentHistoryId!,
        _lastSavedPositionSeconds,
      );
    } finally {
      _currentHistoryId = null;
      _lastSavedPositionSeconds = 0;
    }
  }

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
      debugPrint('PlayerBloc: History finalize error: $e');
    }
  }

  void _updateHandlerMediaItem(NowPlayingData track) {
    try {
      if (GetIt.I.isRegistered<AudioPlayerHandler>()) {
        final handler = GetIt.I<AudioPlayerHandler>();
        handler.updateNowPlaying(track);
      }
    } catch (e) {
      debugPrint('PlayerBloc: Handler update error: $e');
    }
  }

  Future<void> _recordListenToServer(String videoId) async {
    try {
      if (GetIt.I.isRegistered<RecordListenUseCase>()) {
        final recordListenUseCase = GetIt.I<RecordListenUseCase>();
        await recordListenUseCase(videoId);
      }
    } catch (e) {
      debugPrint('PlayerBloc: Record listen error: $e');
    }
  }

  @override
  Future<void> close() async {
    await _finalizeCurrentHistoryEntry();

    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _bufferedPositionSubscription?.cancel();
    await _currentIndexSubscription?.cancel();

    return super.close();
  }
}
