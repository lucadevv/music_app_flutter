import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to remove a genre from favorites.
class RemoveFavoriteGenreUseCase {
  final LibraryRepository _repository;

  RemoveFavoriteGenreUseCase(this._repository);

  /// Execute the use case
  /// [genreId] - The genre ID to remove from favorites
  Future<Either<AppException, void>> call(String genreId) async {
    return _repository.removeFavoriteGenre(genreId);
  }
}
