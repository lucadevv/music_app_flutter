import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to remove a song from a user playlist.
class RemoveSongFromUserPlaylistUseCase {
  final LibraryRepository _repository;

  RemoveSongFromUserPlaylistUseCase(this._repository);

  /// Execute the use case
  /// [playlistId] - The ID of the playlist
  /// [songId] - The ID of the song to remove
  Future<Either<AppException, void>> call(
    String playlistId,
    String songId,
  ) async {
    return _repository.removeSongFromUserPlaylist(playlistId, songId);
  }
}
