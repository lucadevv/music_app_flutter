// ignore_for_file: unintended_html_in_doc_comment
import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';
import '../models/recently_played_song_model.dart';

/// Remote data source for recently played songs.
abstract class RecentlyPlayedRemoteDataSource {
  Future<RecentlyPlayedResponse> getRecentlyPlayed({int limit = 50});
  Future<void> recordListen(String videoId);
}

class RecentlyPlayedRemoteDataSourceImpl
    implements RecentlyPlayedRemoteDataSource {
  final ApiServices _apiServices;

  RecentlyPlayedRemoteDataSourceImpl(this._apiServices);

  @override
  Future<RecentlyPlayedResponse> getRecentlyPlayed({int limit = 50}) async {
    final response = await _apiServices.get(
      '/music/recently-listened?include_stream_urls=true&limit=$limit',
    );
    final data = response is Response ? response.data : response;
    if (data is Map<String, dynamic>) {
      return RecentlyPlayedResponse.fromJson(data);
    }
    return const RecentlyPlayedResponse(songs: [], total: 0);
  }

  @override
  Future<void> recordListen(String videoId) async {
    await _apiServices.post('/music/record-listen', data: {'videoId': videoId});
  }
}
