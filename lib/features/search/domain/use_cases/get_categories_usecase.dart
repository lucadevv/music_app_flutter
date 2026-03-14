import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/home/domain/entities/mood_genre.dart';
import 'package:music_app/features/search/data/data_sources/search_remote_data_source.dart';

/// Use case for getting categories (moods/genres)
class GetCategoriesUseCase {
  final SearchRemoteDataSource _remoteDataSource;

  GetCategoriesUseCase(this._remoteDataSource);

  Future<Either<AppException, List<MoodGenre>>> call() async {
    final result = await _remoteDataSource.getCategories();
    return result.map((models) => models.cast<MoodGenre>());
  }
}
