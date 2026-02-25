import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/search_request.dart';
import '../entities/search_response.dart';
import '../repositories/search_repository.dart';

/// Caso de uso para buscar canciones, artistas, álbumes, etc.
class SearchUseCase {
  final SearchRepository _repository;

  SearchUseCase(this._repository);

  /// Ejecuta la búsqueda
  Future<Either<AppException, SearchResponse>> call(
    SearchRequest request,
  ) async {
    return await _repository.search(request);
  }
}
