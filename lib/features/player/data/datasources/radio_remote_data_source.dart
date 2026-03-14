import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';

/// Data source para obtener playlists de radio (canciones similares)
abstract class RadioRemoteDataSource {
  /// Obtiene canciones similares/radio para un videoId
  Future<List<Map<String, dynamic>>> getRadioPlaylist(String videoId, {int limit = 10});
}

class RadioRemoteDataSourceImpl implements RadioRemoteDataSource {
  final ApiServices _apiServices;

  RadioRemoteDataSourceImpl(this._apiServices);

  @override
  Future<List<Map<String, dynamic>>> getRadioPlaylist(String videoId, {int limit = 10}) async {
    try {
      final response = await _apiServices.get(
        '/music/watch/',
        queryParameters: {
          'video_id': videoId,
          'radio': true,
          'limit': limit,
          'include_stream_urls': true,
        },
      );
      
      final data = response is Response ? response.data : response;
      if (data is Map<String, dynamic>) {
        final tracks = data['tracks'] as List<dynamic>?;
        return tracks?.cast<Map<String, dynamic>>() ?? [];
      }
      return [];
    } on DioException catch (e) {
      // Manejar errores específicos de Dio
      if (e.type == DioExceptionType.cancel) {
        // Petición cancelada - retornar lista vacía silenciosamente
        return [];
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        // Timeout - retornar lista vacía silenciosamente
        return [];
      }
      if (e.type == DioExceptionType.connectionError) {
        // Error de conexión - retornar lista vacía silenciosamente
        return [];
      }
      // Otros errores de Dio - relanzar
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
