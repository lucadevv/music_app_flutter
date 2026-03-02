import 'package:equatable/equatable.dart';

/// Entity for recently played song
class RecentlyPlayedSong extends Equatable {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final String duration;
  final int durationSeconds;
  final DateTime? playedAt;

  const RecentlyPlayedSong({
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    required this.duration,
    this.durationSeconds = 0,
    this.playedAt,
  });

  /// Create from API response
  factory RecentlyPlayedSong.fromJson(Map<String, dynamic> json) {
    final durationStr = json['duration'] ?? '0:00';
    int durationSeconds = 0;

    try {
      final parts = durationStr.toString().split(':');
      if (parts.length == 2) {
        durationSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }
    } catch (_) {}

    return RecentlyPlayedSong(
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? 'Unknown',
      artist: json['artist'] ?? 'Unknown Artist',
      thumbnail: json['thumbnail'],
      duration: durationStr.toString(),
      durationSeconds: durationSeconds,
    );
  }

  @override
  List<Object?> get props => [
    videoId,
    title,
    artist,
    thumbnail,
    duration,
    durationSeconds,
  ];
}
