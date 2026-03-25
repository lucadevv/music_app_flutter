import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to remove a song from favorites.
class RemoveFavoriteSongUseCase {
  final LibraryRepository _repository;

  RemoveFavoriteSongUseCase(this._repository);

  /// Execute the use case
  /// [videoId] - The video ID of the song to remove
  Future<Either<AppException, void>> call(String videoId) async {
    return _repository.removeFavoriteSong(videoId);
  }
}
