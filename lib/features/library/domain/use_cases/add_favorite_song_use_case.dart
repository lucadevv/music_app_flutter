import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to add a song to favorites.
class AddFavoriteSongUseCase {
  final LibraryRepository _repository;

  AddFavoriteSongUseCase(this._repository);

  /// Execute the use case
  /// [song] - The song to add to favorites
  Future<Either<AppException, void>> call(Song song) async {
    return _repository.addFavoriteSong(song);
  }
}
