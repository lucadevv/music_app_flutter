import 'package:music_app/features/search/domain/entities/thumbnail.dart';

/// Entidad para una playlist de mood/genre
class MoodPlaylist {
  final String title;
  final String itemCount;
  final String author;
  final String browseId; // Este es el playlistId que se usa en /api/v1/playlists/{playlistId}
  final List<Thumbnail> thumbnails;
  final String category;
  final String resultType;

  const MoodPlaylist({
    required this.title,
    required this.itemCount,
    required this.author,
    required this.browseId,
    required this.thumbnails,
    required this.category,
    required this.resultType,
  });
}
