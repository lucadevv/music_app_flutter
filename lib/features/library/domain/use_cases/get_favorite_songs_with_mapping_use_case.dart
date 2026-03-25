import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to get favorite songs with videoId -> songId mapping.
/// This mapping is required by FavoriteCubit for proper song removal.
class GetFavoriteSongsWithMappingUseCase {
  final LibraryRepository _repository;

  GetFavoriteSongsWithMappingUseCase(this._repository);

  /// Execute the use case
  /// [page] - Page number (1-indexed)
  /// [limit] - Number of items per page
  Future<Either<AppException, FavoriteSongsWithMapping>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return _repository.getFavoriteSongsWithMapping(page: page, limit: limit);
  }
}
