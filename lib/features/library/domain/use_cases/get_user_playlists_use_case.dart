import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to get user playlists (playlists created by the user).
class GetUserPlaylistsUseCase {
  final LibraryRepository _repository;

  GetUserPlaylistsUseCase(this._repository);

  /// Execute the use case
  /// [page] - Page number (1-indexed)
  /// [limit] - Number of items per page
  Future<Either<AppException, List<UserPlaylist>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return _repository.getUserPlaylists(page: page, limit: limit);
  }
}
