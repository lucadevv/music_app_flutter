// DTO for song metadata (used in search results)
class SongMetadata {
  final String id;
  final String title;
  final String artist;
  final String? thumbnail;
  final int? duration;

  SongMetadata({
    required this.id,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.duration,
  });

  factory SongMetadata.fromJson(Map<String, dynamic> json) {
    return SongMetadata(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      thumbnail: json['thumbnail'],
      duration: json['duration'],
    );
  }
}
