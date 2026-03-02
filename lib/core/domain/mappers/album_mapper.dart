import 'package:music_app/core/domain/entities/album.dart' as core;
import 'package:music_app/features/album/domain/entities/album.dart' as album_feature;

/// Mappers para convertir entre las entidades de Album y la entidad centralizada.
class AlbumMapper {
  /// Crea una instancia de [core.Album] desde la entidad de feature
  static core.Album fromFeatureAlbum(album_feature.Album album) {
    return core.Album(
      id: album.id,
      title: album.title,
      thumbnail: album.thumbnail,
      highThumbnail: album.thumbnail,
      artistName: album.artistName,
      artistId: album.artistId,
      year: album.year,
      songs: album.songs.map(_mapAlbumSong).toList(),
    );
  }

  static core.AlbumSong _mapAlbumSong(album_feature.AlbumSong song) {
    return core.AlbumSong(
      videoId: song.videoId,
      title: song.title,
      thumbnail: song.thumbnail,
      durationSeconds: song.durationSeconds,
      trackNumber: song.trackNumber,
    );
  }

  /// Convierte una lista
  static List<core.Album> fromFeatureAlbumList(List<album_feature.Album> albums) {
    return albums.map(fromFeatureAlbum).toList();
  }
}
