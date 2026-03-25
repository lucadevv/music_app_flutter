import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to get favorite songs with pagination.
class GetFavoriteSongsUseCase {
  final LibraryRepository _repository;

  GetFavoriteSongsUseCase(this._repository);

  /// Execute the use case
  /// [page] - Page number (1-indexed)
  /// [limit] - Number of items per page
  Future<Either<AppException, List<Song>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return _repository.getFavoriteSongs(page: page, limit: limit);
  }
}
