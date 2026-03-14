// ignore_for_file: deprecated_member_use_from_same_package
import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/search/domain/entities/recent_search.dart';
import '../entities/search_request.dart';
import '../entities/search_response.dart';
import '../entities/song.dart';

/// Interfaz del repositorio de búsqueda
/// Define el contrato que debe cumplir cualquier implementación
abstract class SearchRepository {
  /// Busca canciones, artistas, álbumes, etc.
  Future<Either<AppException, SearchResponse>> search(SearchRequest request);

  /// Obtiene las búsquedas recientes
  Future<Either<AppException, List<RecentSearch>>> getRecentSearches({
    int limit = 10,
  });

  /// Actualiza la canción seleccionada en una búsqueda reciente
  Future<Either<AppException, void>> updateSelectedSong({
    required String query,
    required String videoId,
    required Song song,
  });
}
