import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to get favorite playlists with external IDs.
/// Required for proper playlist removal in FavoriteCubit.
class GetFavoritePlaylistsWithMappingUseCase {
  final LibraryRepository _repository;

  GetFavoritePlaylistsWithMappingUseCase(this._repository);

  /// Execute the use case
  /// [page] - Page number (1-indexed)
  /// [limit] - Number of items per page
  Future<Either<AppException, List<FavoritePlaylistEntity>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return _repository.getFavoritePlaylistsWithMapping(
      page: page,
      limit: limit,
    );
  }
}
