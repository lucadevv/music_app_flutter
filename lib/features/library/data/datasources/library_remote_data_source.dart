// ignore_for_file: avoid_dynamic_calls
import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';

/// Remote data source for library feature.
/// Handles all API calls to the backend.
class LibraryRemoteDataSource {
  final ApiServices _api;

  LibraryRemoteDataSource(this._api);

  /// Get library summary (favorite songs count, playlists count, etc.)
  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await _api.get('/library/summary');
      return response is Response ? response.data : response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get favorite songs with pagination
  Future<Map<String, dynamic>> getFavoriteSongs({
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

  /// Get favorite playlists
  Future<Map<String, dynamic>> getFavoritePlaylists({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        '/library/playlists',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response is Response ? response.data : response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get favorite genres
  Future<Map<String, dynamic>> getFavoriteGenres({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        '/library/genres',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response is Response ? response.data : response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addFavoriteSong({
    required String videoId,
    String? title,
    String? artist,
    String? thumbnail,
    int? duration,
    String? streamUrl,
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
          'streamUrl': ?streamUrl,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Remove song from favorites
  Future<void> removeFavoriteSong(String videoId) async {
    try {
      await _api.delete('/library/songs/$videoId');
    } catch (e) {
      rethrow;
    }
  }

  /// Check if song is favorite
  Future<bool> isSongFavorite(String videoId) async {
    try {
      final response = await _api.get('/library/songs/$videoId/check');
      final data = response is Response ? response.data : response;
      return data['isFavorite'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
