// ignore_for_file: avoid_dynamic_calls
import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';

/// Modelo para una canción en favoritos
class FavoriteSongModel {
  final String videoId;
  final String title;
  final String? artist;
  final String? thumbnail;
  final int? durationSeconds;
  final DateTime? addedAt;

  const FavoriteSongModel({
    required this.videoId,
    required this.title,
    this.artist,
    this.thumbnail,
    this.durationSeconds,
    this.addedAt,
  });

  factory FavoriteSongModel.fromJson(Map<String, dynamic> json) {
    return FavoriteSongModel(
      videoId: json['videoId'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown',
      artist: json['artist'] as String?,
      thumbnail: json['thumbnail'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'artist': artist,
      'thumbnail': thumbnail,
      'durationSeconds': durationSeconds,
      'addedAt': addedAt?.toIso8601String(),
    };
  }
}

/// Modelo para la respuesta de favoritos
class FavoritesResponse {
  final List<FavoriteSongModel> songs;
  final int totalCount;
  final int page;
  final int totalPages;

  const FavoritesResponse({
    required this.songs,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    final songsList = json['songs'] as List<dynamic>? ?? [];
    return FavoritesResponse(
      songs: songsList
          .map((s) => FavoriteSongModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

/// Remote data source for favorites feature.
abstract class FavoritesRemoteDataSource {
  Future<FavoritesResponse> getFavorites({int page = 1, int limit = 10});

  Future<void> addFavorite({
    required String videoId,
    String? title,
    String? artist,
    String? thumbnail,
    int? duration,
  });

  Future<void> removeFavorite(String videoId);

  Future<bool> isFavorite(String videoId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final ApiServices _api;

  FavoritesRemoteDataSourceImpl(this._api);

  @override
  Future<FavoritesResponse> getFavorites({int page = 1, int limit = 10}) async {
    final response = await _api.get(
      '/library/songs',
      queryParameters: {
        'page': page,
        'limit': limit,
        'include_stream_urls': true,
      },
    );
    final data = response is Response ? response.data : response;
    if (data is Map<String, dynamic>) {
      return FavoritesResponse.fromJson(data);
    }
    return const FavoritesResponse(
      songs: [],
      totalCount: 0,
      page: 1,
      totalPages: 1,
    );
  }

  @override
  Future<void> addFavorite({
    required String videoId,
    String? title,
    String? artist,
    String? thumbnail,
    int? duration,
  }) async {
    await _api.post(
      '/library/songs',
      data: {
        'videoId': videoId,
        'title': title,
        'artist': artist,
        'thumbnail': thumbnail,
        'duration': duration,
      },
    );
  }

  @override
  Future<void> removeFavorite(String videoId) async {
    await _api.delete('/library/songs/$videoId');
  }

  @override
  Future<bool> isFavorite(String videoId) async {
    try {
      final response = await _api.get('/library/songs/$videoId/check');
      final data = response is Response ? response.data : response;
      if (data is Map<String, dynamic>) {
        return data['isFavorite'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
