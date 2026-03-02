import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/relax/domain/entities/relax_entity.dart';

/// Repository interface for relax/mood operations.
abstract class RelaxRepository {
  /// Get relax playlists (morning, evening, focus, sleep)
  Future<Either<AppException, List<RelaxPlaylistEntity>>> getRelaxPlaylists();
}
