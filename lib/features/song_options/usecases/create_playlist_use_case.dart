import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case for creating a playlist.
class CreatePlaylistUseCase {
  final LibraryRepository _repository;

  CreatePlaylistUseCase(this._repository);

  /// Executes the use case to create a playlist.
  ///
  /// Parameters:
  ///   - name: The name of the playlist to create
  ///   - description: Optional description for the playlist
  ///   - thumbnail: Optional thumbnail URL for the playlist
  ///   - isPublic: Whether the playlist should be public
  ///
  /// Returns:
  ///   A Future containing Either<AppException, UserPlaylist> representing the result
  Future<Either<AppException, UserPlaylist>> call({
    required String name,
    String? description,
    String? thumbnail,
    bool isPublic = false,
  }) async {
    try {
      final response = await _repository.createUserPlaylist(
        name: name,
        description: description,
        thumbnail: thumbnail,
        isPublic: isPublic,
      );
      return Right(response);
    } catch (e) {
      return Left(AppException('Failed to create playlist: $e'));
    }
  }
}
