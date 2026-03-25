// ignore_for_file: deprecated_member_use_from_same_package
import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/artist.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

/// Repository contract for artist data
abstract class ArtistRepository {
  /// Get artist details by ID
  Future<Either<AppException, Artist>> getArtist(String artistId);

  /// Get artist's top songs
  Future<Either<AppException, List<ArtistSong>>> getArtistTopSongs(
    String artistId,
  );

  /// Get artist's albums
  Future<Either<AppException, List<ArtistAlbum>>> getArtistAlbums(
    String artistId,
  );

  /// Follow an artist
  Future<Either<AppException, void>> followArtist(String artistId);

  /// Unfollow an artist
  Future<Either<AppException, void>> unfollowArtist(String artistId);

  /// Check if user follows an artist
  Future<Either<AppException, bool>> isFollowing(String artistId);
}
