import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/core/utils/exeptions/exception_handler.dart';
import '../../domain/entities/mood_playlists_response.dart';
import '../models/mood_playlists_response_model.dart';

/// Data source remoto para operaciones de mood/genre
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Obtener playlists de mood/genre desde la API
abstract class MoodGenreRemoteDataSource {
  /// Obtiene las playlists de un mood/genre
  /// 
  /// Endpoint: /api/music/explore/moods/{params}
  Future<Either<AppException, MoodPlaylistsResponse>> getMoodPlaylists(
    String params,
  );
}

class MoodGenreRemoteDataSourceImpl implements MoodGenreRemoteDataSource {
  final ApiServices _apiServices;

  MoodGenreRemoteDataSourceImpl(this._apiServices);

  @override
  Future<Either<AppException, MoodPlaylistsResponse>> getMoodPlaylists(
    String params,
  ) async {
    try {
      final endpoint = '/music/explore/moods/$params?include_stream_urls=true';
      final response = await _apiServices.get(endpoint);

      // Dio devuelve Response, necesitamos acceder a response.data
      final responseData = response is Response ? response.data : response;

      if (responseData is Map<String, dynamic>) {
        return Right(MoodPlaylistsResponseModel.fromJson(responseData));
      } else {
        final exception = const ServerException(
          'Respuesta del servidor en formato incorrecto',
        );
        ExceptionHandler.logException(exception, context: 'getMoodPlaylists');
        return Left(exception);
      }
    } catch (e) {
      final appException = ExceptionHandler.handleException(e);
      ExceptionHandler.logException(appException, context: 'getMoodPlaylists');
      return Left(appException);
    }
  }
}
