import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';

/// Remote data source for recently played songs
abstract class RecentlyPlayedRemoteDataSource {
  Future<List<RecentlyPlayedSong>> getRecentlyPlayed();
}

class RecentlyPlayedRemoteDataSourceImpl implements RecentlyPlayedRemoteDataSource {
  final ApiServices _apiServices;

  RecentlyPlayedRemoteDataSourceImpl(this._apiServices);

  @override
  Future<List<RecentlyPlayedSong>> getRecentlyPlayed() async {
    final response = await _apiServices.get('/music/recently-listened?include_stream_urls=false');
    
    final List<dynamic> songsData =
        (response is Map<String, dynamic> && response['songs'] is List)
            ? (response['songs'] as List<dynamic>)
            : [];

    return songsData
        .map((json) => RecentlyPlayedSong.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
