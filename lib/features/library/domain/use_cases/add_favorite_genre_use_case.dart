import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to add a genre to favorites.
class AddFavoriteGenreUseCase {
  final LibraryRepository _repository;

  AddFavoriteGenreUseCase(this._repository);

  /// Execute the use case
  /// [externalParams] - The external params identifying the genre
  /// [name] - Optional genre name
  Future<Either<AppException, void>> call({
    required String externalParams,
    String? name,
  }) async {
    return _repository.addFavoriteGenre(externalParams, name: name);
  }
}
