import 'package:equatable/equatable.dart';
import 'package:music_app/core/domain/entities/song.dart';

/// Domain entity representing the current player state
class PlayerStateEntity extends Equatable {
  final Song? currentSong;
  final List<Song> queue;
  final int currentIndex;
  final PlayerStatus status;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final bool isShuffled;
  final bool isRepeating;
  final double volume;

  const PlayerStateEntity({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = 0,
    this.status = PlayerStatus.stopped,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.isShuffled = false,
    this.isRepeating = false,
    this.volume = 1.0,
  });

  @override
  List<Object?> get props => [
    currentSong,
    queue,
    currentIndex,
    status,
    position,
    duration,
    bufferedPosition,
    isShuffled,
    isRepeating,
    volume,
  ];
}

enum PlayerStatus { stopped, playing, paused, loading, error }

/// Domain entity for player queue
class QueueEntity extends Equatable {
  final List<Song> songs;
  final int currentIndex;
  final bool isShuffled;

  const QueueEntity({
    this.songs = const [],
    this.currentIndex = 0,
    this.isShuffled = false,
  });

  Song? get currentSong => songs.isNotEmpty && currentIndex < songs.length
      ? songs[currentIndex]
      : null;

  bool get hasNext => currentIndex < songs.length - 1;
  bool get hasPrevious => currentIndex > 0;

  @override
  List<Object?> get props => [songs, currentIndex, isShuffled];
}
