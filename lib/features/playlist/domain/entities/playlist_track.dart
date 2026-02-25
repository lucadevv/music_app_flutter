import '../../../search/domain/entities/album.dart' show SearchAlbum;
import '../../../search/domain/entities/artist.dart' show SearchArtist;
import '../../../search/domain/entities/thumbnail.dart' show Thumbnail;

/// Entidad del dominio para una canción en una playlist
class PlaylistTrack {
  final String? videoId;
  final String title;
  final List<SearchArtist> artists;
  final SearchAlbum? album;
  final String? likeStatus;
  final bool? inLibrary;
  final bool? pinnedToListenAgain;
  final List<Thumbnail> thumbnails;
  final bool isAvailable;
  final bool isExplicit;
  final String? videoType;
  final String? views;
  final String duration;
  final int durationSeconds;
  final String? streamUrl; // URL de streaming (viene del endpoint con include_stream_urls=true)
  final Thumbnail? thumbnail; // Thumbnail de mejor calidad (viene junto con stream_url)

  const PlaylistTrack({
    this.videoId,
    required this.title,
    required this.artists,
    this.album,
    this.likeStatus,
    this.inLibrary,
    this.pinnedToListenAgain,
    required this.thumbnails,
    required this.isAvailable,
    required this.isExplicit,
    this.videoType,
    this.views,
    required this.duration,
    required this.durationSeconds,
    this.streamUrl,
    this.thumbnail,
  });
}
