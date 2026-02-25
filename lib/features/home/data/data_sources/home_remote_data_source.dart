import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/core/utils/exeptions/exception_handler.dart';
import '../../domain/entities/home_response.dart';
import '../models/home_response_model.dart';

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
      final endpoint = '/music/explore?include_stream_urls=true';
      final response = await _apiServices.get(endpoint);

      // Dio devuelve Response, necesitamos acceder a response.data
      final responseData = response is Response ? response.data : response;

      if (responseData is Map<String, dynamic>) {
        // Debug: Ver qué está llegando de la API
        debugPrint('getHome: Respuesta recibida');
        debugPrint('getHome: moods_genres: ${(responseData['moods_genres'] as List?)?.length ?? 0}');
        debugPrint('getHome: home: ${(responseData['home'] as List?)?.length ?? 0}');
        debugPrint('getHome: charts: ${responseData['charts'] != null ? 'presente' : 'ausente'}');
        
        final homeResponse = HomeResponseModel.fromJson(responseData);
        debugPrint('getHome: HomeResponse parseado - moods: ${homeResponse.moods.length}, genres: ${homeResponse.genres.length}, sections: ${homeResponse.sections.length}');
        
        return Right(homeResponse);
      } else {
        final exception = const ServerException(
          'Respuesta del servidor en formato incorrecto',
        );
        ExceptionHandler.logException(exception, context: 'getHome');
        return Left(exception);
      }
    } catch (e) {
      final appException = ExceptionHandler.handleException(e);
      ExceptionHandler.logException(appException, context: 'getHome');
      return Left(appException);
    }
  }
}
