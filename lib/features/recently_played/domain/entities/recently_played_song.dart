import 'package:equatable/equatable.dart';

/// Entity for recently played song (dominio).
/// Representa la canción en la capa de presentación.
/// El parsing de JSON se hace en el Model (RecentlyPlayedSongModel).
class RecentlyPlayedSong extends Equatable {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final String duration;
  final int durationSeconds;
  final DateTime? playedAt;
  final String? streamUrl;

  const RecentlyPlayedSong({
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    required this.duration,
    this.durationSeconds = 0,
    this.playedAt,
    this.streamUrl,
  });

  @override
  List<Object?> get props => [
        videoId,
        title,
        artist,
        thumbnail,
        duration,
        durationSeconds,
        streamUrl,
      ];
}
