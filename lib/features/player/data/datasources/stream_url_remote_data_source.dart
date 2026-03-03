import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';

/// Data source para obtener stream URL
abstract class StreamUrlRemoteDataSource {
  /// Obtiene la URL de streaming para un videoId
  /// [bypassCache] - Si true, ignora la caché y obtiene URL fresca
  Future<String?> getStreamUrl(String videoId, {bool bypassCache = false});
}

class StreamUrlRemoteDataSourceImpl implements StreamUrlRemoteDataSource {
  final ApiServices _apiServices;

  StreamUrlRemoteDataSourceImpl(this._apiServices);

  @override
  Future<String?> getStreamUrl(String videoId, {bool bypassCache = false}) async {
    try {
      final queryParams = bypassCache ? {'bypass_cache': 'true'} : null;
      final response = await _apiServices.get('/music/stream/$videoId', queryParameters: queryParams);
      
      final data = response is Response ? response.data : response;
      
      if (data is Map<String, dynamic>) {
        // Buscar en múltiples campos posibles: streamUrl, stream_url, url
        return data['streamUrl'] as String? ?? 
               data['stream_url'] as String? ?? 
               data['url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
