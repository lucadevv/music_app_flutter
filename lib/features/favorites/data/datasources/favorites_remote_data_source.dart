// ignore_for_file: avoid_dynamic_calls
import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';

/// Remote data source for favorites feature.
class FavoritesRemoteDataSource {
  final ApiServices _api;

  FavoritesRemoteDataSource(this._api);

  /// Get favorite songs with pagination
  Future<Map<String, dynamic>> getFavorites({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        '/library/songs',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response is Response ? response.data : response;
    } catch (e) {
      rethrow;
    }
  }

  /// Add song to favorites
  Future<void> addFavorite({
    required String videoId,
    String? title,
    String? artist,
    String? thumbnail,
    int? duration,
  }) async {
    try {
      await _api.post(
        '/library/songs',
        data: {
          'videoId': videoId,
          'title': ?title,
          'artist': ?artist,
          'thumbnail': ?thumbnail,
          'duration': ?duration,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Remove song from favorites
  Future<void> removeFavorite(String videoId) async {
    try {
      await _api.delete('/library/songs/$videoId');
    } catch (e) {
      rethrow;
    }
  }

  /// Check if song is favorite
  Future<bool> isFavorite(String videoId) async {
    try {
      final response = await _api.get('/library/songs/$videoId/check');
      final data = response is Response ? response.data : response;
      return data['isFavorite'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
