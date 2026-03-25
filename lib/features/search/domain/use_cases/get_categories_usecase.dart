import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/home/domain/entities/mood_genre.dart';
import 'package:music_app/features/search/domain/repositories/search_repository.dart';

/// Use case for getting categories (moods/genres)
class GetCategoriesUseCase {
  final SearchRepository _repository;

  GetCategoriesUseCase(this._repository);

  Future<Either<AppException, List<MoodGenre>>> call() async {
    return _repository.getCategories();
  }
}
