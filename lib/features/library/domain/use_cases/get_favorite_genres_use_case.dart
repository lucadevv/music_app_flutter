import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to get favorite genres with pagination.
class GetFavoriteGenresUseCase {
  final LibraryRepository _repository;

  GetFavoriteGenresUseCase(this._repository);

  /// Execute the use case
  /// [page] - Page number (1-indexed)
  /// [limit] - Number of items per page
  Future<Either<AppException, List<FavoriteGenreEntity>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return _repository.getFavoriteGenres(page: page, limit: limit);
  }
}
