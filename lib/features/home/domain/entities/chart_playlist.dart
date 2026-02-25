import 'package:music_app/features/search/domain/entities/thumbnail.dart';

/// Entidad para playlists de charts
class ChartPlaylist {
  final String title;
  final String playlistId;
  final List<Thumbnail> thumbnails;

  const ChartPlaylist({
    required this.title,
    required this.playlistId,
    required this.thumbnails,
  });
}
