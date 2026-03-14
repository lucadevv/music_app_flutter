import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/core/utils/exeptions/exception_handler.dart';
import 'package:music_app/features/home/data/isolates/home_response_parsing_isolate.dart';

import '../../domain/entities/home_response.dart';

/// Data source remoto para operaciones del home
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Obtener datos del home desde la API
abstract class HomeRemoteDataSource {
  /// Obtiene los datos del home
  ///
  /// Endpoint: /api/music/explore
  Future<Either<AppException, HomeResponse>> getHome();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiServices _apiServices;

  HomeRemoteDataSourceImpl(this._apiServices);

  @override
  Future<Either<AppException, HomeResponse>> getHome() async {
    try {
      if (kDebugMode) {
        debugPrint('HomeRemoteDataSource: Calling /music/explore');
      }
      
      const endpoint = '/music/explore?include_stream_urls=false';
      final response = await _apiServices.get(endpoint);

      if (kDebugMode) {
        debugPrint('HomeRemoteDataSource: Response received');
      }

      // Dio devuelve Response, necesitamos acceder a response.data
      final responseData = response is Response ? response.data : response;

      if (kDebugMode) {
        debugPrint('HomeRemoteDataSource: responseData type = ${responseData.runtimeType}');
      }

      if (responseData is Map<String, dynamic>) {
        // Off-loading JSON parsing a un Isolate Secundario (Performance)
        final homeResponse = await HomeResponseParsingIsolate.parseResponse(responseData);
        
        if (kDebugMode) {
          debugPrint(
            'getHome: HomeResponse parseado - moods: ${homeResponse.moods.length}, genres: ${homeResponse.genres.length}, sections: ${homeResponse.sections.length}',
          );
        }

        return Right(homeResponse);
      } else {
        const exception = ServerException(
          'Respuesta del servidor en formato incorrecto',
        );
        ExceptionHandler.logException(exception, context: 'getHome');
        return const Left(exception);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HomeRemoteDataSource: Exception - $e');
      }
      final appException = ExceptionHandler.handleException(e);
      ExceptionHandler.logException(appException, context: 'getHome');
      return Left(appException);
    }
  }
}
