import '../../domain/entities/song.dart' as domain;
import 'search_album_model.dart';
import 'search_artist_model.dart';
import 'thumbnail_model.dart';

/// Modelo de datos para una canción en los resultados de búsqueda
class SongModel extends domain.Song {
  const SongModel({
    required super.title,
    required super.album,
    required super.artists,
    required super.videoId,
    required super.duration,
    required super.durationSeconds,
    required super.views,
    required super.isExplicit,
    required super.inLibrary,
    required super.thumbnails,
    super.streamUrl,
    super.thumbnail,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      title: json['title'] as String? ?? '',
      album: json['album'] != null
          ? SearchAlbumModel.fromJson(json['album'] as Map<String, dynamic>)
          : const domain.SearchAlbum(name: '', id: '', artists: []),
      artists: json['artists'] != null
          ? (json['artists'] as List<dynamic>)
              .map(
                (artist) => SearchArtistModel.fromJson(
                  artist as Map<String, dynamic>,
                ),
              )
              .toList()
          : <domain.SearchArtist>[],
      videoId: json['videoId'] as String? ?? '',
      duration: json['duration'] as String? ?? '0:00',
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      views: json['views'] as String? ?? '0',
      isExplicit: json['isExplicit'] as bool? ?? false,
      inLibrary: json['inLibrary'] as bool? ?? false,
      thumbnails: json['thumbnails'] != null
          ? (json['thumbnails'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(
                (thumb) => domain.Thumbnail(
                  url: thumb['url'] as String? ?? '',
                  width: thumb['width'] as int?,
                  height: thumb['height'] as int?,
                ),
              )
              .toList()
          : <domain.Thumbnail>[],
      streamUrl: json['stream_url'] as String?,
      thumbnail: json['thumbnail'] != null
          ? (json['thumbnail'] is Map<String, dynamic>
              ? domain.Thumbnail(
                  url: (json['thumbnail'] as Map<String, dynamic>)['url'] as String? ?? '',
                  width: (json['thumbnail'] as Map<String, dynamic>)['width'] as int?,
                  height: (json['thumbnail'] as Map<String, dynamic>)['height'] as int?,
                )
              : null)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'album': (album as SearchAlbumModel).toJson(),
      'artists': artists
          .map((artist) => (artist as SearchArtistModel).toJson())
          .toList(),
      'videoId': videoId,
      'duration': duration,
      'duration_seconds': durationSeconds,
      'views': views,
      'isExplicit': isExplicit,
      'inLibrary': inLibrary,
      'thumbnails': thumbnails
          .map((thumb) => (thumb as ThumbnailModel).toJson())
          .toList(),
      if (streamUrl != null) 'stream_url': streamUrl,
      if (thumbnail != null) 'thumbnail': (thumbnail as ThumbnailModel).toJson(),
    };
  }
}
