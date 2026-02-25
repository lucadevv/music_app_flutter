part of 'player_bloc_bloc.dart';

/// Estados del reproductor
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Representar el estado del reproductor
sealed class PlayerBlocState extends Equatable {
  const PlayerBlocState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del reproductor
final class PlayerBlocInitial extends PlayerBlocState {
  const PlayerBlocInitial();
}

/// Estado del reproductor con toda la información
class PlayerBlocLoaded extends PlayerBlocState {
  final PlaybackState playbackState;
  final ProcessingState processingState; // De just_audio
  final AudioConnectionState connectionState;
  final List<NowPlayingData> playlist;
  final int? currentIndex;
  final NowPlayingData? currentTrack;
  final String? currentStreamUrl; // URL de streaming obtenida del endpoint
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final double volume;
  final double speed;
  final LoopMode loopMode;
  final bool isShuffleEnabled;
  final String? error;
  final bool isLoading;

  const PlayerBlocLoaded({
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
  });

  /// Getters computados para facilitar el uso
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
      hasPlaylist &&
      currentIndex != null &&
      currentIndex! < playlist.length - 1;
  bool get canPlayPrevious =>
      hasPlaylist && currentIndex != null && currentIndex! > 0;

  /// Progreso de reproducción (0.0 a 1.0)
  double get progress {
    if (duration.inMilliseconds <= 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  /// Progreso del buffer (0.0 a 1.0)
  double get bufferedProgress {
    if (duration.inMilliseconds <= 0) return 0.0;
    return bufferedPosition.inMilliseconds / duration.inMilliseconds;
  }

  /// Método para crear una copia del estado con cambios
  PlayerBlocLoaded copyWith({
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
    bool clearError = false,
    bool clearCurrentTrack = false,
    bool clearCurrentIndex = false,
    bool clearCurrentStreamUrl = false,
  }) {
    return PlayerBlocLoaded(
      playbackState: playbackState ?? this.playbackState,
      processingState: processingState ?? this.processingState,
      connectionState: connectionState ?? this.connectionState,
      playlist: playlist ?? this.playlist,
      currentIndex:
          clearCurrentIndex ? null : (currentIndex ?? this.currentIndex),
      currentTrack:
          clearCurrentTrack ? null : (currentTrack ?? this.currentTrack),
      currentStreamUrl: clearCurrentStreamUrl
          ? null
          : (currentStreamUrl ?? this.currentStreamUrl),
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      loopMode: loopMode ?? this.loopMode,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
    );
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
      ];
}

/// Enums para el estado del reproductor
enum PlaybackState { stopped, playing, paused }

enum AudioConnectionState { connected, connecting, disconnected }
