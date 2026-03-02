import 'package:music_app/features/artist/domain/entities/artist.dart';

/// Repository contract for artist data
abstract class ArtistRepository {
  /// Get artist details by ID
  Future<Artist> getArtist(String artistId);

  /// Get artist's top songs
  Future<List<ArtistSong>> getArtistTopSongs(String artistId);

  /// Get artist's albums
  Future<List<ArtistAlbum>> getArtistAlbums(String artistId);

  /// Follow/unfollow an artist
  Future<void> followArtist(String artistId);
  Future<void> unfollowArtist(String artistId);

  /// Check if user follows an artist
  Future<bool> isFollowing(String artistId);
}
