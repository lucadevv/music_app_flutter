import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to add a playlist to favorites.
class AddFavoritePlaylistUseCase {
  final LibraryRepository _repository;

  AddFavoritePlaylistUseCase(this._repository);

  /// Execute the use case
  /// [externalPlaylistId] - The external playlist ID to add to favorites
  /// [name] - Optional playlist name
  /// [thumbnail] - Optional playlist thumbnail
  /// [description] - Optional playlist description
  /// [trackCount] - Optional track count
  Future<Either<AppException, void>> call({
    required String externalPlaylistId,
    String? name,
    String? thumbnail,
    String? description,
    int? trackCount,
  }) async {
    return _repository.addFavoritePlaylist(
      externalPlaylistId,
      name: name,
      thumbnail: thumbnail,
      description: description,
      trackCount: trackCount,
    );
  }
}
