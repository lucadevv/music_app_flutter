import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/core/utils/exeptions/exception_handler.dart';
import '../../domain/entities/search_request.dart';
import '../models/search_response_model.dart';
import '../models/recent_search_model.dart';
import '../../domain/entities/recent_search.dart';

/// Data source remoto para operaciones de búsqueda
abstract class SearchRemoteDataSource {
  Future<Either<AppException, SearchResponseModel>> search(
    SearchRequest request,
  );

  Future<Either<AppException, List<RecentSearch>>> getRecentSearches({
    int limit = 10,
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
      final endpoint = '/music/search?q=$encodedQuery&filter=${request.filter}&include_stream_urls=true';

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
      final endpoint = '/music/recent-searches?limit=$limit&include_stream_urls=true';
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
              debugPrint('getRecentSearches: Item $i es String (solo query), saltando: $item');
              continue;
            } 
            // Si el item es un Map, parsearlo normalmente
            else if (item is Map<String, dynamic>) {
              recentSearches.add(RecentSearchModel.fromJson(item));
            }
            // Si el item es otro tipo, intentar convertirlo
            else {
              debugPrint('getRecentSearches: Item $i tiene tipo inesperado: ${item.runtimeType}, valor: $item');
              // Intentar convertir a Map si es posible
              try {
                final itemMap = Map<String, dynamic>.from(item as Map);
                recentSearches.add(RecentSearchModel.fromJson(itemMap));
              } catch (castError) {
                debugPrint('getRecentSearches: Error convirtiendo item $i a Map: $castError');
                continue;
              }
            }
          } catch (e, stackTrace) {
            // Si falla el parseo de un item, loguear y continuar con los demás
            debugPrint('getRecentSearches: Error parseando item $i: $e');
            debugPrint('getRecentSearches: Stack trace: $stackTrace');
            debugPrint('getRecentSearches: Item que causó el error: $item (tipo: ${item.runtimeType})');
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
                debugPrint('getRecentSearches: Item $i en data es String, saltando: $item');
                continue;
              }
            } catch (e) {
              debugPrint('getRecentSearches: Error parseando item $i en data: $e');
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
}
