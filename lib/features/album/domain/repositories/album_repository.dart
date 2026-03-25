// ignore_for_file: deprecated_member_use_from_same_package
import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/album/domain/entities/album.dart';

/// Repository contract for album data
abstract class AlbumRepository {
  /// Get album details by ID
  Future<Either<AppException, Album>> getAlbum(String albumId);

  /// Get album songs
  Future<Either<AppException, List<AlbumSong>>> getAlbumSongs(String albumId);

  /// Like an album
  Future<Either<AppException, void>> likeAlbum(String albumId);

  /// Unlike an album
  Future<Either<AppException, void>> unlikeAlbum(String albumId);

  /// Check if album is liked
  Future<Either<AppException, bool>> isLiked(String albumId);
}
