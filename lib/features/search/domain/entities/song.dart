import 'album.dart';
import 'artist.dart';
import 'thumbnail.dart';

/// Entidad del dominio para una canción en los resultados de búsqueda
class Song {
  final String title;
  final SearchAlbum album;
  final List<SearchArtist> artists;
  final String videoId;
  final String duration;
  final int durationSeconds;
  final String views;
  final bool isExplicit;
  final bool inLibrary;
  final List<Thumbnail> thumbnails;
  final String? streamUrl; // URL de streaming (viene del endpoint con include_stream_urls=true)
  final Thumbnail? thumbnail; // Thumbnail de mejor calidad (viene junto con stream_url)

  const Song({
    required this.title,
    required this.album,
    required this.artists,
    required this.videoId,
    required this.duration,
    required this.durationSeconds,
    required this.views,
    required this.isExplicit,
    required this.inLibrary,
    required this.thumbnails,
    this.streamUrl,
    this.thumbnail,
  });
}
