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
    // Parse album
    domain.SearchAlbum album;
    if (json['album'] != null) {
      final albumModel = SearchAlbumModel.fromJson(json['album'] as Map<String, dynamic>);
      album = domain.SearchAlbum(
        id: albumModel.id,
        name: albumModel.name,
        artists: albumModel.artists.map((a) => domain.SearchArtist(id: a.id, name: a.name)).toList(),
      );
    } else {
      album = const domain.SearchAlbum(id: '', name: '', artists: []);
    }

    // Parse artists
    List<domain.SearchArtist> artists = [];
    if (json['artists'] != null) {
      artists = (json['artists'] as List<dynamic>)
          .map((artist) {
            final model = SearchArtistModel.fromJson(artist as Map<String, dynamic>);
            return domain.SearchArtist(id: model.id, name: model.name);
          })
          .toList();
    }

    // Parse thumbnails
    List<domain.Thumbnail> thumbnails = [];
    if (json['thumbnails'] != null) {
      thumbnails = (json['thumbnails'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((thumb) => domain.Thumbnail(
                url: thumb['url'] as String? ?? '',
                width: thumb['width'] as int?,
                height: thumb['height'] as int?,
              ))
          .toList();
    }

    // Parse thumbnail (best quality)
    domain.Thumbnail? thumbnail;
    if (json['thumbnail'] != null) {
      if (json['thumbnail'] is Map<String, dynamic>) {
        final thumb = json['thumbnail'] as Map<String, dynamic>;
        thumbnail = domain.Thumbnail(
          url: thumb['url'] as String? ?? '',
          width: thumb['width'] as int?,
          height: thumb['height'] as int?,
        );
      }
    }

    return SongModel(
      title: json['title'] as String? ?? '',
      album: album,
      artists: artists,
      videoId: json['videoId'] as String? ?? '',
      duration: json['duration'] as String? ?? '0:00',
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      views: json['views'] as String? ?? '0',
      isExplicit: json['isExplicit'] as bool? ?? false,
      inLibrary: json['inLibrary'] as bool? ?? false,
      thumbnails: thumbnails,
      streamUrl: json['stream_url'] as String?,
      thumbnail: thumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'album': (album is SearchAlbumModel) ? (album as SearchAlbumModel).toJson() : {'id': album.id, 'name': album.name},
      'artists': artists.map((a) => {'id': a.id, 'name': a.name}).toList(),
      'videoId': videoId,
      'duration': duration,
      'duration_seconds': durationSeconds,
      'views': views,
      'isExplicit': isExplicit,
      'inLibrary': inLibrary,
      'thumbnails': thumbnails.map((t) => {'url': t.url, 'width': t.width, 'height': t.height}).toList(),
      if (streamUrl != null) 'stream_url': streamUrl,
      if (thumbnail != null) 'thumbnail': {'url': thumbnail!.url, 'width': thumbnail!.width, 'height': thumbnail!.height},
    };
  }
}
