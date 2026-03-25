import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to update a user playlist.
class UpdateUserPlaylistUseCase {
  final LibraryRepository _repository;

  UpdateUserPlaylistUseCase(this._repository);

  /// Execute the use case
  /// [playlistId] - The ID of the playlist to update
  /// [name] - New name for the playlist (optional)
  /// [description] - New description for the playlist (optional)
  /// [thumbnail] - New thumbnail URL for the playlist (optional)
  /// [isPublic] - Whether the playlist is public (optional)
  Future<Either<AppException, UserPlaylistDetail>> call(
    String playlistId, {
    String? name,
    String? description,
    String? thumbnail,
    bool? isPublic,
  }) async {
    return _repository.updateUserPlaylist(
      playlistId,
      name: name,
      description: description,
      thumbnail: thumbnail,
      isPublic: isPublic,
    );
  }
}
