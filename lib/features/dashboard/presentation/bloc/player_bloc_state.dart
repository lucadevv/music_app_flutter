part of 'player_bloc_bloc.dart';

/// Estado único del reproductor
class PlayerBlocState extends Equatable {
  final PlaybackState playbackState;
  final ProcessingState processingState;
  final AudioConnectionState connectionState;
  final List<NowPlayingData> playlist;
  final int? currentIndex;
  final NowPlayingData? currentTrack;
  final String? currentStreamUrl;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final double volume;
  final double speed;
  final LoopMode loopMode;
  final bool isShuffleEnabled;
  final String? error;
  final bool isLoading;
  final DateTime? loadingCompletedAt;
  final int? loadedCount;
  final int? totalToLoad;

  const PlayerBlocState({
    this.playbackState = PlaybackState.stopped,
    this.processingState = ProcessingState.idle,
    this.connectionState = AudioConnectionState.disconnected,
    this.playlist = const [],
    this.currentIndex,
    this.currentTrack,
    this.currentStreamUrl,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.volume = 1.0,
    this.speed = 1.0,
    this.loopMode = LoopMode.off,
    this.isShuffleEnabled = false,
    this.error,
    this.isLoading = false,
    this.loadingCompletedAt,
    this.loadedCount,
    this.totalToLoad,
  });

  /// Factory para estado inicial
  factory PlayerBlocState.initial() => const PlayerBlocState(
        playbackState: PlaybackState.stopped,
        processingState: ProcessingState.idle,
        connectionState: AudioConnectionState.disconnected,
        playlist: [],
        currentIndex: null,
        currentTrack: null,
        currentStreamUrl: null,
        position: Duration.zero,
        duration: Duration.zero,
        bufferedPosition: Duration.zero,
        volume: 1.0,
        speed: 1.0,
        loopMode: LoopMode.off,
        isShuffleEnabled: false,
        error: null,
        isLoading: false,
        loadingCompletedAt: null,
        loadedCount: null,
        totalToLoad: null,
  );

  /// copyWith
  PlayerBlocState copyWith({
    PlaybackState? playbackState,
    ProcessingState? processingState,
    AudioConnectionState? connectionState,
    List<NowPlayingData>? playlist,
    int? currentIndex,
    NowPlayingData? currentTrack,
    String? currentStreamUrl,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    double? volume,
    double? speed,
    LoopMode? loopMode,
    bool? isShuffleEnabled,
    String? error,
    bool? isLoading,
    DateTime? loadingCompletedAt,
    int? loadedCount,
    int? totalToLoad,
    bool clearError = false,
    bool clearCurrentTrack = false,
    bool clearCurrentIndex = false,
  }) {
    return PlayerBlocState(
      playbackState: playbackState ?? this.playbackState,
      processingState: processingState ?? this.processingState,
      connectionState: connectionState ?? this.connectionState,
      playlist: playlist ?? this.playlist,
      currentIndex: clearCurrentIndex ? null : (currentIndex ?? this.currentIndex),
      currentTrack: clearCurrentTrack ? null : (currentTrack ?? this.currentTrack),
      currentStreamUrl: currentStreamUrl ?? this.currentStreamUrl,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      loopMode: loopMode ?? this.loopMode,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
      loadingCompletedAt: loadingCompletedAt ?? this.loadingCompletedAt,
      loadedCount: loadedCount ?? this.loadedCount,
      totalToLoad: totalToLoad ?? this.totalToLoad,
    );
  }

  /// Getters
  bool get isPlaying => playbackState == PlaybackState.playing;
  bool get isPaused => playbackState == PlaybackState.paused;
  bool get isStopped => playbackState == PlaybackState.stopped;
  bool get isBuffering => processingState == ProcessingState.buffering;
  bool get isReady => processingState == ProcessingState.ready;
  bool get isCompleted => processingState == ProcessingState.completed;
  bool get hasError => error != null;
  bool get hasPlaylist => playlist.isNotEmpty;
  bool get hasCurrentTrack => currentTrack != null;
  bool get canPlayNext =>
      hasPlaylist && currentIndex != null && currentIndex! < playlist.length - 1;
  bool get canPlayPrevious =>
      hasPlaylist && currentIndex != null && currentIndex! > 0;

  bool get isPlaylistFullyLoaded => loadingCompletedAt != null && !isLoading;
  bool get isPlaylistLoading =>
      isLoading && loadedCount != null && totalToLoad != null && loadedCount! < totalToLoad!;

  double get loadingProgress {
    if (totalToLoad == null || totalToLoad == 0) return 0.0;
    if (loadedCount == null) return 0.0;
    return loadedCount! / totalToLoad!;
  }

  double get progress {
    if (duration.inMilliseconds <= 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  double get bufferedProgress {
    if (duration.inMilliseconds <= 0) return 0.0;
    return bufferedPosition.inMilliseconds / duration.inMilliseconds;
  }

  @override
  List<Object?> get props => [
        playbackState,
        processingState,
        connectionState,
        playlist,
        currentIndex,
        currentTrack,
        currentStreamUrl,
        position,
        duration,
        bufferedPosition,
        volume,
        speed,
        loopMode,
        isShuffleEnabled,
        error,
        isLoading,
        loadingCompletedAt,
        loadedCount,
        totalToLoad,
      ];
}

enum PlaybackState { stopped, playing, paused }

enum AudioConnectionState { connected, connecting, disconnected }
