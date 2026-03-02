import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/offline/domain/entities/offline_song_entity.dart';

/// Repository interface for offline operations.
abstract class OfflineRepository {
  /// Check if device is online
  Future<Either<AppException, bool>> isOnline();

  /// Get all downloaded songs
  Future<Either<AppException, List<OfflineSongEntity>>> getDownloadedSongs();

  /// Download a song for offline use (requires streamUrl)
  Future<Either<AppException, void>> downloadSong(OfflineSongEntity song, String streamUrl);

  /// Remove downloaded song
  Future<Either<AppException, void>> removeDownload(String videoId);

  /// Get download status
  Future<Either<AppException, String>> getDownloadStatus(String videoId);

  /// Sync favorites when back online (requires server songs list)
  Future<Either<AppException, void>> syncFavorites(List<Map<String, dynamic>> serverSongs);
}
