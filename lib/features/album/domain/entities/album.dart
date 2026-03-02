/// Entity representing an album
class Album {
  final String id;
  final String title;
  final String? thumbnail;
  final String? artistName;
  final String? artistId;
  final int year;
  final List<AlbumSong> songs;

  const Album({
    required this.id,
    required this.title,
    this.thumbnail,
    this.artistName,
    this.artistId,
    this.year = 2024,
    this.songs = const [],
  });

  String get bestThumbnail => thumbnail ?? '';

  int get songCount => songs.length;

  int get totalDurationSeconds => songs.fold(0, (sum, song) => sum + song.durationSeconds);

  String get formattedDuration {
    final totalMinutes = totalDurationSeconds ~/ 60;
    return '$totalMinutes min';
  }
}

/// Song from an album
class AlbumSong {
  final String videoId;
  final String title;
  final String? thumbnail;
  final int durationSeconds;
  final int trackNumber;

  const AlbumSong({
    required this.videoId,
    required this.title,
    this.thumbnail,
    required this.durationSeconds,
    required this.trackNumber,
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
