import '../../../search/domain/entities/thumbnail.dart' show Thumbnail;
import 'playlist_author.dart' show PlaylistAuthor;
import 'playlist_track.dart' show PlaylistTrack;

/// Entidad del dominio para la respuesta de una playlist
class PlaylistResponse {
  final bool owned;
  final String id;
  final String privacy;
  final String description;
  final int views;
  final String duration;
  final int trackCount;
  final String title;
  final List<Thumbnail> thumbnails;
  final PlaylistAuthor author;
  final String year;
  final List<dynamic> related;
  final List<PlaylistTrack> tracks;
  final int durationSeconds;

  const PlaylistResponse({
    required this.owned,
    required this.id,
    required this.privacy,
    required this.description,
    required this.views,
    required this.duration,
    required this.trackCount,
    required this.title,
    required this.thumbnails,
    required this.author,
    required this.year,
    required this.related,
    required this.tracks,
    required this.durationSeconds,
  });
}
