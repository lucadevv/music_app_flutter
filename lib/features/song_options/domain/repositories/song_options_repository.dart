import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/song_options/domain/entities/song_option_entity.dart';

/// Repository interface for song options operations.
abstract class SongOptionsRepository {
  /// Get song options (favorite status, download status)
  Future<Either<AppException, SongOptionEntity>> getSongOptions(String videoId);

  /// Toggle favorite status
  Future<Either<AppException, SongOptionEntity>> toggleFavorite(SongOptionEntity song);

  /// Download song (requires streamUrl)
  Future<Either<AppException, void>> downloadSong(SongOptionEntity song, String streamUrl);

  /// Remove download
  Future<Either<AppException, void>> removeDownload(String videoId);
}
