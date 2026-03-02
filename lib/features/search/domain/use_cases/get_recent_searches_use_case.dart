import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/recent_search.dart';
import '../repositories/search_repository.dart';

/// Caso de uso para obtener búsquedas recientes
class GetRecentSearchesUseCase {
  final SearchRepository _repository;

  GetRecentSearchesUseCase(this._repository);

  /// Ejecuta la obtención de búsquedas recientes
  Future<Either<AppException, List<RecentSearch>>> call({
    int limit = 10,
  }) async {
    return _repository.getRecentSearches(limit: limit);
  }
}
