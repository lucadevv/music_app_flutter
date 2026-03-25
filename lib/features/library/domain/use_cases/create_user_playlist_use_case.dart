import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to create a user playlist.
class CreateUserPlaylistUseCase {
  final LibraryRepository _repository;

  CreateUserPlaylistUseCase(this._repository);

  /// Execute the use case
  /// [name] - Name of the playlist
  /// [description] - Optional description
  /// [thumbnail] - Optional thumbnail URL
  /// [isPublic] - Whether the playlist is public
  Future<Either<AppException, UserPlaylist>> call({
    required String name,
    String? description,
    String? thumbnail,
    bool isPublic = false,
  }) async {
    return _repository.createUserPlaylist(
      name: name,
      description: description,
      thumbnail: thumbnail,
      isPublic: isPublic,
    );
  }
}
