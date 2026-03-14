// ignore_for_file: deprecated_member_use_from_same_package
import 'package:music_app/core/domain/entities/artist.dart' as core;
import 'package:music_app/features/artist/domain/entities/artist.dart'
    as artist_feature;

/// Mappers para convertir entre las entidades de Artist y la entidad centralizada.
class ArtistMapper {
  /// Crea una instancia de [core.Artist] desde la entidad de feature
  static core.Artist fromFeatureArtist(artist_feature.Artist artist) {
    return core.Artist(
      id: artist.id,
      name: artist.name,
      thumbnail: artist.thumbnail,
      highThumbnail: artist.thumbnail,
      monthlyListeners: artist.monthlyListeners,
      description: artist.description,
      topSongs: artist.topSongs.map(_mapArtistSong).toList(),
      albums: artist.albums.map(_mapArtistAlbum).toList(),
    );
  }

  static core.ArtistSong _mapArtistSong(artist_feature.ArtistSong song) {
    return core.ArtistSong(
      videoId: song.videoId,
      title: song.title,
      thumbnail: song.thumbnail,
      durationSeconds: song.durationSeconds,
      views: song.views,
    );
  }

  static core.ArtistAlbum _mapArtistAlbum(artist_feature.ArtistAlbum album) {
    return core.ArtistAlbum(
      id: album.id,
      title: album.title,
      thumbnail: album.thumbnail,
      year: album.year,
      songCount: album.songCount,
    );
  }

  /// Convierte una lista
  static List<core.Artist> fromFeatureArtistList(
    List<artist_feature.Artist> artists,
  ) {
    return artists.map(fromFeatureArtist).toList();
  }
}
