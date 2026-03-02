import 'package:equatable/equatable.dart';

/// Entity representing a queue item.
class QueueItemEntity extends Equatable {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final int? duration;

  const QueueItemEntity({
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.duration,
  });

  @override
  List<Object?> get props => [videoId, title, artist, thumbnail, duration];
}

/// Entity representing the current queue state.
class QueueEntity extends Equatable {
  final QueueItemEntity? currentSong;
  final List<QueueItemEntity> upNext;
  final List<QueueItemEntity> history;

  const QueueEntity({
    this.currentSong,
    this.upNext = const [],
    this.history = const [],
  });

  QueueEntity copyWith({
    QueueItemEntity? currentSong,
    List<QueueItemEntity>? upNext,
    List<QueueItemEntity>? history,
  }) {
    return QueueEntity(
      currentSong: currentSong ?? this.currentSong,
      upNext: upNext ?? this.upNext,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [currentSong, upNext, history];
}
