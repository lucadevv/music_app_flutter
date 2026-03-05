import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/core/utils/exeptions/exception_handler.dart';
import '../../domain/entities/playlist_response.dart';
import '../isolates/playlist_response_parsing_isolate.dart';

/// Data source remoto para operaciones de playlist
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Obtener datos de playlist desde la API
abstract class PlaylistRemoteDataSource {
  /// Obtiene los datos de una playlist
  ///
  /// Endpoint: /api/music/playlists/{id}
  /// Soporta paginación con startIndex y limit
  Future<Either<AppException, PlaylistResponse>> getPlaylist(
    String id, {
    int startIndex = 0,
    int limit = 20,
  });
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final ApiServices _apiServices;

  PlaylistRemoteDataSourceImpl(this._apiServices);

  @override
  Future<Either<AppException, PlaylistResponse>> getPlaylist(
    String id, {
    int startIndex = 0,
    int limit = 20,
  }) async {
    try {
      // Validar que el ID no esté vacío
      if (id.isEmpty) {
        const exception = ValidationException(
          'El ID de la playlist no puede estar vacío',
        );
        ExceptionHandler.logException(exception, context: 'getPlaylist');
        return const Left(exception);
      }

      final endpoint = '/music/playlists/$id?include_stream_urls=true&start_index=$startIndex&limit=$limit';
      final response = await _apiServices.get(endpoint);

      // Dio devuelve Response, necesitamos acceder a response.data
      final responseData = response is Response ? response.data : response;

      if (responseData is Map<String, dynamic>) {
        // Usar isolate para playlists grandes
        final playlist = await PlaylistResponseParsingIsolate.parseInIsolate(
          responseData,
        );
        return Right(playlist);
      } else {
        const exception = ServerException(
          'Respuesta del servidor en formato incorrecto',
        );
        ExceptionHandler.logException(exception, context: 'getPlaylist');
        return const Left(exception);
      }
    } catch (e) {
      final appException = ExceptionHandler.handleException(e);
      ExceptionHandler.logException(appException, context: 'getPlaylist');
      return Left(appException);
    }
  }
}
