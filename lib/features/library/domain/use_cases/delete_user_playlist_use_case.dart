import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to delete a user playlist.
class DeleteUserPlaylistUseCase {
  final LibraryRepository _repository;

  DeleteUserPlaylistUseCase(this._repository);

  /// Execute the use case
  /// [playlistId] - The ID of the playlist to delete
  Future<Either<AppException, void>> call(String playlistId) async {
    return _repository.deleteUserPlaylist(playlistId);
  }
}
