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
        '/music/radio/$videoId',
        queryParameters: {'limit': limit},
      );
      
      final data = response is Response ? response.data : response;
      if (data is Map<String, dynamic>) {
        final tracks = data['tracks'] as List<dynamic>?;
        return tracks?.cast<Map<String, dynamic>>() ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
