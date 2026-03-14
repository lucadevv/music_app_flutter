// ignore_for_file: deprecated_member_use_from_same_package
import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/search/domain/entities/recent_search.dart';
import '../../domain/entities/search_request.dart';
import '../../domain/entities/search_response.dart';
import '../../domain/entities/song.dart';

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
    return _remoteDataSource.search(request);
  }

  @override
  Future<Either<AppException, List<RecentSearch>>> getRecentSearches({
    int limit = 10,
  }) async {
    return _remoteDataSource.getRecentSearches(limit: limit);
  }

  @override
  Future<Either<AppException, void>> updateSelectedSong({
    required String query,
    required String videoId,
    required Song song,
  }) async {
    return _remoteDataSource.updateSelectedSong(
      query: query,
      videoId: videoId,
      song: song,
    );
  }
}
