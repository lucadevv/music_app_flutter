import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/liked/domain/entities/liked_song_entity.dart';

/// Repository interface for liked songs operations.
abstract class LikedRepository {
  /// Get all liked songs
  Future<Either<AppException, List<LikedSongEntity>>> getLikedSongs({
    int page = 1,
    int limit = 20,
  });

  /// Add song to liked
  Future<Either<AppException, void>> addLikedSong(LikedSongEntity song);

  /// Remove song from liked
  Future<Either<AppException, void>> removeLikedSong(String videoId);

  /// Check if song is liked
  Future<Either<AppException, bool>> isSongLiked(String videoId);
}
