import 'package:equatable/equatable.dart';

/// Entity representing a liked song in the domain layer.
class LikedSongEntity extends Equatable {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final int? duration;
  final DateTime? addedAt;

  const LikedSongEntity({
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.duration,
    this.addedAt,
  });

  @override
  List<Object?> get props => [videoId, title, artist, thumbnail, duration, addedAt];
}
