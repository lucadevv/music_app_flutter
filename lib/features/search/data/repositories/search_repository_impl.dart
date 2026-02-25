import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../../domain/entities/search_request.dart';
import '../../domain/entities/search_response.dart';
import '../../domain/entities/recent_search.dart';
import '../../domain/repositories/search_repository.dart';
import '../data_sources/search_remote_data_source.dart';

/// Implementación del repositorio de búsqueda
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;

  SearchRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, SearchResponse>> search(
    SearchRequest request,
  ) async {
    return await _remoteDataSource.search(request);
  }

  @override
  Future<Either<AppException, List<RecentSearch>>> getRecentSearches({
    int limit = 10,
  }) async {
    return await _remoteDataSource.getRecentSearches(limit: limit);
  }
}
