import 'package:music_app/features/search/domain/entities/album.dart';
import 'package:music_app/features/search/domain/entities/artist.dart';
import 'package:music_app/features/search/domain/entities/thumbnail.dart';

/// Entidad para items de contenido en las secciones de home
/// Puede ser una canción (con videoId) o una playlist (con playlistId)
class HomeContentItem {
  final String title;
  final String? videoId;
  final String? playlistId;
  final List<Thumbnail> thumbnails;
  final bool isExplicit;
  final List<SearchArtist> artists;
  final String views;
  final SearchAlbum? album;
  final String? description; // Para playlists
  final String? streamUrl; // URL de streaming (viene del endpoint con include_stream_urls=true)
  final Thumbnail? thumbnail; // Thumbnail de mejor calidad (viene junto con stream_url)

  const HomeContentItem({
    required this.title,
    this.videoId,
    this.playlistId,
    required this.thumbnails,
    this.isExplicit = false,
    required this.artists,
    this.views = '0',
    this.album,
    this.description,
    this.streamUrl,
    this.thumbnail,
  });

  /// Verifica si es una canción
  bool get isSong => videoId != null && videoId!.isNotEmpty;

  /// Verifica si es una playlist
  bool get isPlaylist => playlistId != null && playlistId!.isNotEmpty;
}
