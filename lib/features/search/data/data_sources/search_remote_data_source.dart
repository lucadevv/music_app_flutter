import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/core/utils/exeptions/exception_handler.dart';
import 'package:music_app/features/home/data/models/mood_genre_model.dart';
import 'package:music_app/features/search/data/models/recent_search_model.dart';
import 'package:music_app/features/search/domain/entities/recent_search.dart';
import '../../domain/entities/search_request.dart';
import '../../domain/entities/song.dart';
import '../models/search_response_model.dart';

/// Data source remoto para operaciones de búsqueda
abstract class SearchRemoteDataSource {
  Future<Either<AppException, SearchResponseModel>> search(
    SearchRequest request,
  );

  Future<Either<AppException, List<RecentSearch>>> getRecentSearches({
    int limit = 10,
  });

  /// Obtiene las categorías (moods/genres) para la pantalla de búsqueda
  Future<Either<AppException, List<MoodGenreModel>>> getCategories();

  /// Actualiza la canción seleccionada en una búsqueda reciente
  Future<Either<AppException, void>> updateSelectedSong({
    required String query,
    required String videoId,
    required Song song,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiServices _apiServices;

  SearchRemoteDataSourceImpl(this._apiServices);

  @override
  Future<Either<AppException, SearchResponseModel>> search(
    SearchRequest request,
  ) async {
    try {
      // Codificar la query para URL (espacios -> %20)
      final encodedQuery = Uri.encodeComponent(request.query);
      
      // Construir endpoint con paginación
      final endpoint = '/music/search?q=$encodedQuery&filter=${request.filter}'
          '&start_index=${request.startIndex}&include_stream_urls=false';

      final response = await _apiServices.get(endpoint);

      // Dio devuelve Response, necesitamos acceder a response.data
      final responseData = response is Response ? response.data : response;

      // La respuesta puede venir directamente como Map o anidada
      Map<String, dynamic> jsonData;
      if (responseData is Map<String, dynamic>) {
        jsonData = responseData;
      } else if (responseData is String) {
        // Si viene como String, es un error - la API debería retornar JSON
        final exception = ServerException(
          'Respuesta del servidor en formato incorrecto: recibido String en lugar de JSON. Respuesta: $responseData',
        );
        ExceptionHandler.logException(exception, context: 'search');
        return Left(exception);
      } else {
        final exception = ServerException(
          'Respuesta del servidor en formato incorrecto: tipo ${responseData.runtimeType}. Valor: $responseData',
        );
        ExceptionHandler.logException(exception, context: 'search');
        return Left(exception);
      }

      // Validar que tenga la estructura esperada
      if (!jsonData.containsKey('results')) {
        final exception = ServerException(
          'Respuesta del servidor sin campo "results". Campos disponibles: ${jsonData.keys.join(", ")}',
        );
        ExceptionHandler.logException(exception, context: 'search');
        return Left(exception);
      }

      return Right(SearchResponseModel.fromJson(jsonData));
    } catch (e) {
      final appException = ExceptionHandler.handleException(e);
      ExceptionHandler.logException(appException, context: 'search');
      return Left(appException);
    }
  }

  @override
  Future<Either<AppException, List<RecentSearch>>> getRecentSearches({
    int limit = 10,
  }) async {
    try {
      final endpoint =
          '/music/recent-searches?limit=$limit&include_stream_urls=false';
      final response = await _apiServices.get(endpoint);

      // Dio devuelve Response, necesitamos acceder a response.data
      final responseData = response is Response ? response.data : response;

      if (responseData is List) {
        final recentSearches = <RecentSearch>[];

        for (var i = 0; i < responseData.length; i++) {
          final item = responseData[i];
          try {
            // Si el item es un String, es solo el query (formato simple)
            // La API puede retornar solo strings o objetos completos
            if (item is String) {
              // Saltar items que son solo strings - la API debería retornar objetos completos
              if (kDebugMode)
                debugPrint(
                  'getRecentSearches: Item $i es String (solo query), saltando: $item',
                );
              continue;
            }
            // Si el item es un Map, parsearlo normalmente
            else if (item is Map<String, dynamic>) {
              recentSearches.add(RecentSearchModel.fromJson(item));
            }
            // Si el item es otro tipo, intentar convertirlo
            else {
              if (kDebugMode)
                debugPrint(
                  'getRecentSearches: Item $i tiene tipo inesperado: ${item.runtimeType}, valor: $item',
                );
              // Intentar convertir a Map si es posible
              try {
                final itemMap = Map<String, dynamic>.from(item as Map);
                recentSearches.add(RecentSearchModel.fromJson(itemMap));
              } catch (castError) {
                if (kDebugMode)
                  debugPrint(
                    'getRecentSearches: Error convirtiendo item $i a Map: $castError',
                  );
                continue;
              }
            }
          } catch (e, stackTrace) {
            // Si falla el parseo de un item, loguear y continuar con los demás
            if (kDebugMode) {
              debugPrint('getRecentSearches: Error parseando item $i: $e');
              debugPrint('getRecentSearches: Stack trace: $stackTrace');
              debugPrint(
                'getRecentSearches: Item que causó el error: $item (tipo: ${item.runtimeType})',
              );
            }
            continue;
          }
        }

        return Right(recentSearches);
      } else if (responseData is Map<String, dynamic>) {
        // La API puede retornar un objeto con una lista dentro
        if (responseData.containsKey('data') && responseData['data'] is List) {
          // Parsear la lista anidada
          final dataList = responseData['data'] as List;
          final recentSearches = <RecentSearch>[];

          for (var i = 0; i < dataList.length; i++) {
            final item = dataList[i];
            try {
              if (item is Map<String, dynamic>) {
                recentSearches.add(RecentSearchModel.fromJson(item));
              } else if (item is String) {
             
              }
            } catch (e) {
             
              continue;
            }
          }

          return Right(recentSearches);
        }
        final exception = ServerException(
          'Respuesta del servidor en formato incorrecto: recibido Map en lugar de List. Campos: ${responseData.keys.join(", ")}',
        );
        ExceptionHandler.logException(exception, context: 'getRecentSearches');
        return Left(exception);
      } else {
        final exception = ServerException(
          'Respuesta del servidor en formato incorrecto: tipo ${responseData.runtimeType}. Valor: $responseData',
        );
        ExceptionHandler.logException(exception, context: 'getRecentSearches');
        return Left(exception);
      }
    } catch (e) {
      final appException = ExceptionHandler.handleException(e);
      ExceptionHandler.logException(appException, context: 'getRecentSearches');
      return Left(appException);
    }
  }

  @override
  Future<Either<AppException, List<MoodGenreModel>>> getCategories() async {
    try {
      const endpoint = '/music/explore?include_stream_urls=false';
      final response = await _apiServices.get(endpoint);

      final responseData = response is Response ? response.data : response;

      if (responseData is Map<String, dynamic>) {
        final moodsGenresList =
            responseData['moods_genres'] as List<dynamic>? ?? [];

        final categories = moodsGenresList
            .map((json) => MoodGenreModel.fromJson(json as Map<String, dynamic>))
            .where((category) => category.params.isNotEmpty)
            .toList();

        return Right(categories);
      } else {
        return Left(ServerException('Respuesta del servidor en formato incorrecto'));
      }
    } catch (e) {
      final appException = ExceptionHandler.handleException(e);
      ExceptionHandler.logException(appException, context: 'getCategories');
      return Left(appException);
    }
  }

  @override
  Future<Either<AppException, void>> updateSelectedSong({
    required String query,
    required String videoId,
    required Song song,
  }) async {
    try {
      const endpoint = '/music/recent-searches/select';
      
      final body = {
        'query': query,
        'videoId': videoId,
        'songData': {
          'videoId': song.videoId,
          'title': song.title,
          'artists': song.artists.map((a) => {'id': a.id, 'name': a.name}).toList(),
          'album': {'id': song.album.id, 'name': song.album.name},
          'thumbnails': song.thumbnails.map((t) => {'url': t.url, 'width': t.width, 'height': t.height}).toList(),
          'duration': song.duration,
          'durationSeconds': song.durationSeconds,
          'views': song.views,
        },
      };

      await _apiServices.put(endpoint, data: body);
      return const Right(null);
    } catch (e) {
      final appException = ExceptionHandler.handleException(e);
      ExceptionHandler.logException(appException, context: 'updateSelectedSong');
      return Left(appException);
    }
  }
}
