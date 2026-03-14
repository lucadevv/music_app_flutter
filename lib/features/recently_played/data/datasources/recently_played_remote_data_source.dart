import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/recently_played/data/models/recently_played_song_model.dart';

/// Remote data source for recently played songs.
/// Sigue el patrón de Clean Architecture: retorna Map<String, dynamic> 
/// que se convierte a modelo en el repository.
abstract class RecentlyPlayedRemoteDataSource {
  Future<Map<String, dynamic>> getRecentlyPlayed();
  Future<void> recordListen(String videoId);
}

class RecentlyPlayedRemoteDataSourceImpl implements RecentlyPlayedRemoteDataSource {
  final ApiServices _apiServices;

  RecentlyPlayedRemoteDataSourceImpl(this._apiServices);

  @override
  Future<Map<String, dynamic>> getRecentlyPlayed() async {
    try {
      final response = await _apiServices.get('/music/recently-listened?include_stream_urls=false');
      // Handle Dio Response wrapper - return data or the response itself
      return response is Response ? response.data : response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> recordListen(String videoId) async {
    await _apiServices.post(
      '/music/record-listen',
      data: {'videoId': videoId},
    );
  }
}
