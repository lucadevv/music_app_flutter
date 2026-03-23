import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/services/audio_handler_service.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/domain/player_engine.dart';
import 'package:music_app/features/player/domain/repositories/player_repository.dart';
import 'package:music_app/features/player/domain/types/player_types.dart';
import 'package:music_app/features/player/domain/usecases/manage_history_use_case.dart';
import 'package:music_app/features/player/infrastructure/just_audio_player_engine.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';

part 'player_bloc_event.dart';
part 'player_bloc_state.dart';

class PlayerBlocBloc extends Bloc<PlayerBlocEvent, PlayerBlocState> {
  final AudioPlayerHandler? _playerHandler;
  final PlayerRepository _repository;
  final ManageHistoryUseCase _manageHistoryUseCase;

  PlayerEngine? _engine;
  bool _isEngineInitialized = false;
  final PlayerEngine? _engineOverride;

  ProfileCubit? _profileCubit;
  set profileCubit(ProfileCubit cubit) => _profileCubit = cubit;

  final _playlistPlaybackStartedController =
      StreamController<PlaylistPlaybackStartedEvent>.broadcast();
  Stream<PlaylistPlaybackStartedEvent> get playlistPlaybackStartedStream =>
      _playlistPlaybackStartedController.stream;

  PlayerEngine get _playerEngine {
    if (_engineOverride != null) return _engineOverride;
    if (_engine != null) return _engine!;
    final handler = _playerHandler;
    if (handler == null) {
      throw StateError('PlayerBlocBloc: playerHandler is required');
    }
    _engine = JustAudioPlayerEngine(handler.player);
    return _engine!;
  }

  String? _lastLoadedVideoId;
  String? _lastLoadedSourceId;
  bool _isLoadingTrack = false;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _bufferedPositionSubscription;
  StreamSubscription? _currentIndexSubscription;

  PlayerBlocBloc({
    AudioPlayerHandler? playerHandler,
    PlayerEngine? engine,
    required PlayerRepository repository,
    required ManageHistoryUseCase manageHistoryUseCase,
  }) : _playerHandler = playerHandler,
       _engineOverride = engine,
       _repository = repository,
       _manageHistoryUseCase = manageHistoryUseCase,
       super(PlayerBlocState.initial()) {
    _registerEventHandlers();
    if (_engineOverride != null) _initializeEngine();
  }

  void _initializeEngine() {
    if (_isEngineInitialized) return;
    final engine = _engineOverride ?? _playerEngine;

    _playerStateSubscription = engine.playerStateStream.listen(
      (s) => add(AudioPlayerStateChangedEvent(s)),
    );
    _positionSubscription = engine.positionStream.listen(
      (p) => add(PositionChangedEvent(p)),
    );
    _durationSubscription = engine.durationStream.listen(
      (d) => add(DurationChangedEvent(d ?? Duration.zero)),
    );
    _bufferedPositionSubscription = engine.bufferedPositionStream.listen(
      (p) => add(BufferedPositionChangedEvent(p)),
    );
    _currentIndexSubscription = engine.currentIndexStream.listen(
      (i) => add(CurrentIndexChangedEvent(i)),
    );

    _isEngineInitialized = true;
  }

  void _ensureEngineInitialized() {
    if (!_isEngineInitialized) _initializeEngine();
  }

  void _registerEventHandlers() {
    on<PlayEvent>((_, emit) async {
      _ensureEngineInitialized();
      await _playerEngine.play();
    });
    on<PauseEvent>((_, emit) async {
      _ensureEngineInitialized();
      await _playerEngine.pause();
    });
    on<StopEvent>(_onStop);
    on<PlayPauseToggleEvent>(
      (_, emit) =>
          add(state.isPlaying ? const PauseEvent() : const PlayEvent()),
    );

    on<NextTrackEvent>(_onNextTrack);
    on<PreviousTrackEvent>(_onPreviousTrack);
    on<SeekEvent>((e, _) async {
      _ensureEngineInitialized();
      await _playerEngine.seek(e.position);
    });

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
    on<DurationChangedEvent>(
      (e, emit) => emit(state.copyWith(duration: e.duration)),
    );
    on<BufferedPositionChangedEvent>(
      (e, emit) => emit(state.copyWith(bufferedPosition: e.bufferedPosition)),
    );
    on<CurrentIndexChangedEvent>(_onCurrentIndexChanged);
    on<AudioErrorEvent>(
      (e, emit) => emit(
        state.copyWith(
          error: e.error,
          processingState: ProcessingStateType.idle,
        ),
      ),
    );

    on<InitializeAudioServiceEvent>(
      (_, emit) =>
          emit(state.copyWith(connectionState: AudioConnectionState.connected)),
    );
    on<DisposeAudioServiceEvent>(
      (_, emit) => emit(
        state.copyWith(connectionState: AudioConnectionState.disconnected),
      ),
    );
    on<ResetPlayerEvent>(_onResetPlayer);
    on<PlaylistPlaybackStartedEvent>(
      (e, _) =>
          debugPrint('PlayerBloc: Playlist playback started - ${e.sourceId}'),
    );
  }

  Future<void> _onStop(_, Emitter<PlayerBlocState> emit) async {
    _ensureEngineInitialized();
    await _playerEngine.stop();
    await _manageHistoryUseCase.finalizeCurrent();
    emit(state.copyWith(position: Duration.zero));
  }

  Future<void> _onNextTrack(_, Emitter<PlayerBlocState> emit) async {
    _ensureEngineInitialized();
    if (state.canPlayNext) await _playerEngine.seekToNext();
  }

  Future<void> _onPreviousTrack(_, Emitter<PlayerBlocState> emit) async {
    _ensureEngineInitialized();
    if (state.canPlayPrevious) await _playerEngine.seekToPrevious();
  }

  Future<void> _onPlayRequest(
    PlayRequestEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    if (state.currentTrack?.videoId == e.track.videoId) {
      if (!state.isPlaying) add(const PlayEvent());
      return;
    }
    if (e.playAsSingle) {
      await _handleLoadTrack(e.track, 'single:${e.track.videoId}', emit);
      return;
    }
    final idx = state.playlist.indexWhere((t) => t.videoId == e.track.videoId);
    if (idx >= 0) {
      await _handlePlayTrackAtIndex(idx, emit);
    } else {
      await _handleLoadTrack(e.track, null, emit);
    }
  }

  Future<void> _onLoadTrack(
    LoadTrackEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    await _handleLoadTrack(e.track, e.sourceId, emit);
  }

  Future<void> _handleLoadTrack(
    NowPlayingData track,
    String? sourceId,
    Emitter<PlayerBlocState> emit,
  ) async {
    if (_isLoadingTrack &&
        _lastLoadedVideoId == track.videoId &&
        _lastLoadedSourceId == sourceId)
      return;

    _isLoadingTrack = true;
    _lastLoadedVideoId = track.videoId;
    _lastLoadedSourceId = sourceId;

    try {
      String? streamUrl = track.streamUrl;
      final localPath = await _repository.getLocalAudioPath(track.videoId);
      if (localPath != null && localPath.isNotEmpty) {
        streamUrl = 'file://$localPath';
      }

      if (streamUrl == null || streamUrl.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'No se pudo obtener URL'));
        return;
      }

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

      final audioConfig = AudioSourceConfig(
        id: track.videoId,
        url: streamUrl,
        title: track.title,
        artist: track.artistsNames,
        duration: Duration(seconds: track.durationSeconds),
        mediaItem: track.toMediaItem(),
      );
      await _playerEngine.setAudioSource(audioConfig, preload: false);
      _updateHandlerMediaItem(track);

      final duration = Duration(
        seconds: track.durationSeconds > 0 ? track.durationSeconds : 0,
      );
      emit(
        state.copyWith(
          playbackState: PlaybackState.playing,
          processingState: ProcessingStateType.ready,
          connectionState: AudioConnectionState.connected,
          currentTrack: track,
          currentStreamUrl: streamUrl,
          currentIndex: 0,
          duration: duration,
          position: Duration.zero,
          isLoading: false,
          error: null,
        ),
      );

      await _playerEngine.play();
      await _manageHistoryUseCase.startNewEntry(track.toSong());
      unawaited(_repository.recordListen(track.videoId));
    } catch (e) {
      debugPrint('PlayerBloc: Error loading track: $e');
      emit(state.copyWith(isLoading: false, error: 'Error al cargar: $e'));
    } finally {
      if (_lastLoadedVideoId == track.videoId &&
          _lastLoadedSourceId == sourceId) {
        _isLoadingTrack = false;
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
    if (track.streamUrl == null || track.streamUrl!.isEmpty) {
      emit(state.copyWith(error: 'La canción no tiene URL'));
      return;
    }

    if (state.currentIndex == index &&
        state.currentTrack?.videoId == track.videoId) {
      if (!state.isPlaying) {
        await _playerEngine.play();
        emit(state.copyWith(playbackState: PlaybackState.playing));
      }
      return;
    }

    await _playerEngine.seek(Duration.zero, index: index);
    await _playerEngine.play();
    _updateHandlerMediaItem(track);
    emit(
      state.copyWith(
        playbackState: PlaybackState.playing,
        currentIndex: index,
        currentTrack: track,
        currentStreamUrl: track.streamUrl,
      ),
    );
  }

  Future<void> _onLoadPlaylist(
    LoadPlaylistEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    if (e.playlist.isEmpty) {
      emit(state.copyWith(isLoading: false, error: 'Playlist vacía'));
      return;
    }

    final startIdx = (e.startIndex ?? 0).clamp(0, e.playlist.length - 1);
    emit(state.copyWith(isLoading: true, error: null));

    final sources = <AudioSourceConfig>[];
    for (final t in e.playlist) {
      if (t.streamUrl != null && t.streamUrl!.isNotEmpty) {
        try {
          sources.add(
            AudioSourceConfig(
              id: t.videoId,
              url: t.streamUrl!,
              title: t.title,
              artist: t.artistsNames,
              duration: Duration(seconds: t.durationSeconds),
              mediaItem: t.toMediaItem(),
            ),
          );
        } catch (_) {}
      }
    }

    if (sources.isEmpty) {
      emit(
        state.copyWith(isLoading: false, error: 'No se pudieron cargar URLs'),
      );
      return;
    }

    await _playerEngine.setAudioSources(sources, preload: false);
    await _playerEngine.setLoopMode(LoopModeType.all);

    final first = e.playlist[startIdx];
    _updateHandlerMediaItem(first);
    final duration = Duration(
      seconds: first.durationSeconds > 0 ? first.durationSeconds : 0,
    );

    emit(
      state.copyWith(
        playbackState: PlaybackState.playing,
        playlist: e.playlist,
        isLoading: false,
        connectionState: AudioConnectionState.connected,
        currentIndex: startIdx,
        currentTrack: first,
        currentStreamUrl: first.streamUrl,
        duration: duration,
        position: Duration.zero,
        sourceId: e.sourceId,
        error: null,
      ),
    );

    await _playerEngine.seek(Duration.zero, index: startIdx);
    await _playerEngine.play();
    await _manageHistoryUseCase.startNewEntry(first.toSong());
    unawaited(_repository.recordListen(first.videoId));
    _playlistPlaybackStartedController.add(
      PlaylistPlaybackStartedEvent(sourceId: e.sourceId),
    );
  }

  Future<void> _onPlayTrackAtIndex(
    PlayTrackAtIndexEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    await _handlePlayTrackAtIndex(e.index, emit);
  }

  Future<void> _onAddToPlaylist(
    AddToPlaylistEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    if (e.track.streamUrl == null || e.track.streamUrl!.isEmpty) {
      emit(state.copyWith(error: 'La canción no tiene URL'));
      return;
    }
    if (state.playlist.any((t) => t.videoId == e.track.videoId)) return;

    await _playerEngine.addAudioSources([
      AudioSourceConfig(
        id: e.track.videoId,
        url: e.track.streamUrl!,
        title: e.track.title,
        artist: e.track.artistsNames,
        duration: Duration(seconds: e.track.durationSeconds),
        mediaItem: e.track.toMediaItem(),
      ),
    ]);
    emit(state.copyWith(playlist: [...state.playlist, e.track]));
  }

  Future<void> _onAddMultipleToPlaylist(
    AddMultipleToPlaylistEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    final existing = state.playlist.map((t) => t.videoId).toSet();
    final valid = e.tracks
        .where(
          (t) =>
              t.streamUrl != null &&
              t.streamUrl!.isNotEmpty &&
              !existing.contains(t.videoId),
        )
        .toList();
    if (valid.isEmpty) return;

    await _playerEngine.addAudioSources(
      valid
          .map(
            (t) => AudioSourceConfig(
              id: t.videoId,
              url: t.streamUrl!,
              title: t.title,
              artist: t.artistsNames,
              duration: Duration(seconds: t.durationSeconds),
              mediaItem: t.toMediaItem(),
            ),
          )
          .toList(),
    );
    emit(state.copyWith(playlist: [...state.playlist, ...valid]));
  }

  Future<void> _onRemoveFromPlaylist(
    RemoveFromPlaylistEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    if (e.index < 0 || e.index >= state.playlist.length) return;

    final removed = state.playlist[e.index];
    final wasCurrent = state.currentTrack?.videoId == removed.videoId;
    final newPlaylist = List<NowPlayingData>.from(state.playlist)
      ..removeAt(e.index);

    await _playerEngine.removeAudioSourceAt(e.index);

    if (wasCurrent) {
      if (newPlaylist.isEmpty) {
        await _playerEngine.stop();
        emit(
          state.copyWith(
            playlist: [],
            clearCurrentIndex: true,
            clearCurrentTrack: true,
            currentStreamUrl: null,
            playbackState: PlaybackState.stopped,
            processingState: ProcessingStateType.idle,
            position: Duration.zero,
          ),
        );
        return;
      }
      final safeIdx = e.index >= newPlaylist.length
          ? newPlaylist.length - 1
          : e.index;
      final next = newPlaylist[safeIdx];
      await _playerEngine.seek(Duration.zero, index: safeIdx);
      emit(
        state.copyWith(
          playlist: newPlaylist,
          currentIndex: safeIdx,
          currentTrack: next,
          currentStreamUrl: next.streamUrl,
        ),
      );
      return;
    }
    emit(state.copyWith(playlist: newPlaylist));
  }

  Future<void> _onSetVolume(
    SetVolumeEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    final v = e.volume.clamp(0.0, 1.0);
    await _playerEngine.setVolume(v);
    emit(state.copyWith(volume: v));
  }

  Future<void> _onSetSpeed(
    SetSpeedEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    final s = e.speed.clamp(0.5, 2.0);
    await _playerEngine.setSpeed(s);
    emit(state.copyWith(speed: s));
  }

  Future<void> _onSetLoopMode(
    SetLoopModeEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    await _playerEngine.setLoopMode(e.loopMode);
    emit(state.copyWith(loopMode: e.loopMode));
  }

  Future<void> _onToggleShuffle(
    ToggleShuffleEvent _,
    Emitter<PlayerBlocState> emit,
  ) async {
    _ensureEngineInitialized();
    final newState = !state.isShuffleEnabled;
    await _playerEngine.setShuffleModeEnabled(newState);
    emit(state.copyWith(isShuffleEnabled: newState));
  }

  Future<void> _onAudioPlayerStateChanged(
    AudioPlayerStateChangedEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    final prevProcessing = state.processingState;
    final pbState = e.playerState.isPlaying
        ? PlaybackState.playing
        : PlaybackState.paused;
    emit(
      state.copyWith(
        playbackState: pbState,
        processingState: e.playerState.processingState,
      ),
    );

    if (prevProcessing != ProcessingStateType.completed &&
        e.playerState.processingState == ProcessingStateType.completed) {
      await _handleAutoPlay();
    }
  }

  Future<void> _handleAutoPlay() async {
    final autoPlay = _profileCubit?.state.settings?.autoPlay ?? true;
    if (!autoPlay || state.loopMode == LoopModeType.one) return;
    if (state.canPlayNext) {
      add(const NextTrackEvent());
    } else if (state.loopMode == LoopModeType.all &&
        state.playlist.isNotEmpty) {
      add(const PlayTrackAtIndexEvent(0));
    }
  }

  Future<void> _onPositionChanged(
    PositionChangedEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    emit(state.copyWith(position: e.position));
    unawaited(_manageHistoryUseCase.updatePlayedDuration(e.position.inSeconds));
  }

  Future<void> _onCurrentIndexChanged(
    CurrentIndexChangedEvent e,
    Emitter<PlayerBlocState> emit,
  ) async {
    final track = e.index != null && e.index! < state.playlist.length
        ? state.playlist[e.index!]
        : null;

    if (track != null && e.index != state.currentIndex) {
      _updateHandlerMediaItem(track);
      await _manageHistoryUseCase.startNewEntry(track.toSong());
      unawaited(_repository.recordListen(track.videoId));
    }
    emit(state.copyWith(currentIndex: e.index, currentTrack: track));
  }

  Future<void> _onResetPlayer(_, Emitter<PlayerBlocState> emit) async {
    await _playerEngine.stop();
    await _playerEngine.setAudioSources([]);
    await _manageHistoryUseCase.finalizeCurrent();
    emit(PlayerBlocState.initial());
  }

  void _updateHandlerMediaItem(NowPlayingData track) {
    try {
      _playerHandler?.updateNowPlaying(track);
    } catch (e) {
      debugPrint('PlayerBloc: Handler update error: $e');
    }
  }

  @override
  Future<void> close() async {
    await _manageHistoryUseCase.finalizeCurrent();
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _bufferedPositionSubscription?.cancel();
    await _currentIndexSubscription?.cancel();
    await _playlistPlaybackStartedController.close();
    return super.close();
  }
}
