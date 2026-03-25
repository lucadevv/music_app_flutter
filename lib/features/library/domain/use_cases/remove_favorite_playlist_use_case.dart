import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to remove a playlist from favorites.
class RemoveFavoritePlaylistUseCase {
  final LibraryRepository _repository;

  RemoveFavoritePlaylistUseCase(this._repository);

  /// Execute the use case
  /// [playlistId] - The playlist ID to remove from favorites
  Future<Either<AppException, void>> call(String playlistId) async {
    return _repository.removeFavoritePlaylist(playlistId);
  }
}
