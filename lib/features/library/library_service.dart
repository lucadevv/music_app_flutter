import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';

class SongMetadata {
  final String? title;
  final String? artist;
  final String? thumbnail;
  final int? duration;

  const SongMetadata({
    this.title,
    this.artist,
    this.thumbnail,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (artist != null) 'artist': artist,
    if (thumbnail != null) 'thumbnail': thumbnail,
    if (duration != null) 'duration': duration,
  };
}

class PlaylistMetadata {
  final String? name;
  final String? thumbnail;
  final String? description;

  const PlaylistMetadata({
    this.name,
    this.thumbnail,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (thumbnail != null) 'thumbnail': thumbnail,
    if (description != null) 'description': description,
  };
}

class LibraryService {
  final ApiServices _apiServices;

  LibraryService(this._apiServices);

  Future<LibrarySummary> getLibrarySummary() async {
    try {
      final response = await _apiServices.get('/library/summary');
      final data = response is Response ? response.data : response;
      return LibrarySummary.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<FavoriteSongsResponse> getFavoriteSongs({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiServices.get(
        '/library/songs',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response is Response ? response.data : response;
      return FavoriteSongsResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<FavoritePlaylistsResponse> getFavoritePlaylists({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiServices.get(
        '/library/playlists',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response is Response ? response.data : response;
      return FavoritePlaylistsResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<FavoriteGenresResponse> getFavoriteGenres({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiServices.get(
        '/library/genres',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response is Response ? response.data : response;
      return FavoriteGenresResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addFavoriteSong(
    String videoId, {
    String? title,
    String? artist,
    String? thumbnail,
    int? duration,
  }) async {
    try {
      await _apiServices.post(
        '/library/songs',
        data: {
          'videoId': videoId,
          if (title != null) 'title': title,
          if (artist != null) 'artist': artist,
          if (thumbnail != null) 'thumbnail': thumbnail,
          if (duration != null) 'duration': duration,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFavoriteSong(String songId) async {
    try {
      await _apiServices.delete('/library/songs/$songId');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isSongFavorite(String songId) async {
    try {
      final response = await _apiServices.get('/library/songs/$songId/check');
      final data = response is Response ? response.data : response;
      return data['isFavorite'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> addFavoritePlaylist(
    String externalPlaylistId, {
    String? name,
    String? thumbnail,
    String? description,
  }) async {
    try {
      await _apiServices.post(
        '/library/playlists',
        data: {
          'externalPlaylistId': externalPlaylistId,
          if (name != null) 'name': name,
          if (thumbnail != null) 'thumbnail': thumbnail,
          if (description != null) 'description': description,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFavoritePlaylist(String playlistId) async {
    try {
      await _apiServices.delete('/library/playlists/$playlistId');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isPlaylistFavorite(String playlistId) async {
    try {
      final response = await _apiServices.get('/library/playlists/$playlistId/check');
      final data = response is Response ? response.data : response;
      return data['isFavorite'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> addFavoriteGenre(String externalParams, {String? name}) async {
    try {
      await _apiServices.post(
        '/library/genres',
        data: {'externalParams': externalParams, if (name != null) 'name': name},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFavoriteGenre(String genreId) async {
    try {
      await _apiServices.delete('/library/genres/$genreId');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isGenreFavorite(String genreId) async {
    try {
      final response = await _apiServices.get('/library/genres/$genreId/check');
      final data = response is Response ? response.data : response;
      return data['isFavorite'] ?? false;
    } catch (e) {
      return false;
    }
  }
}

class LibrarySummary {
  final int favoriteSongs;
  final int favoritePlaylists;
  final int favoriteGenres;

  LibrarySummary({
    required this.favoriteSongs,
    required this.favoritePlaylists,
    required this.favoriteGenres,
  });

  factory LibrarySummary.fromJson(Map<String, dynamic> json) {
    return LibrarySummary(
      favoriteSongs: json['favoriteSongs'] ?? 0,
      favoritePlaylists: json['favoritePlaylists'] ?? 0,
      favoriteGenres: json['favoriteGenres'] ?? 0,
    );
  }
}

class FavoriteSongsResponse {
  final List<FavoriteSong> data;
  final int total;

  FavoriteSongsResponse({
    required this.data,
    required this.total,
  });

  factory FavoriteSongsResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteSongsResponse(
      data: (json['data'] as List?)
          ?.map((e) => FavoriteSong.fromJson(e))
          .toList() ?? [],
      total: json['total'] ?? 0,
    );
  }
}

class FavoriteSong {
  final String id;
  final String songId;
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final int? duration;
  final DateTime createdAt;

  FavoriteSong({
    required this.id,
    required this.songId,
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.duration,
    required this.createdAt,
  });

  factory FavoriteSong.fromJson(Map<String, dynamic> json) {
    final song = json['song'] as Map<String, dynamic>?;
    return FavoriteSong(
      id: json['id'] ?? '',
      songId: song?['id'] ?? '',
      videoId: song?['videoId'] ?? '',
      title: song?['title'] ?? '',
      artist: song?['artist'] ?? '',
      thumbnail: song?['thumbnail'],
      duration: song?['duration'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class FavoritePlaylistsResponse {
  final List<FavoritePlaylist> data;
  final int total;

  FavoritePlaylistsResponse({
    required this.data,
    required this.total,
  });

  factory FavoritePlaylistsResponse.fromJson(Map<String, dynamic> json) {
    return FavoritePlaylistsResponse(
      data: (json['data'] as List?)
          ?.map((e) => FavoritePlaylist.fromJson(e))
          .toList() ?? [],
      total: json['total'] ?? 0,
    );
  }
}

class FavoritePlaylist {
  final String id;
  final String playlistId;
  final String externalPlaylistId;
  final String name;
  final String? description;
  final String? thumbnail;
  final int? trackCount;
  final DateTime createdAt;

  FavoritePlaylist({
    required this.id,
    required this.playlistId,
    required this.externalPlaylistId,
    required this.name,
    this.description,
    this.thumbnail,
    this.trackCount,
    required this.createdAt,
  });

  factory FavoritePlaylist.fromJson(Map<String, dynamic> json) {
    final playlist = json['playlist'] as Map<String, dynamic>?;
    return FavoritePlaylist(
      id: json['id'] ?? '',
      playlistId: playlist?['id'] ?? '',
      externalPlaylistId: playlist?['externalPlaylistId'] ?? '',
      name: playlist?['name'] ?? '',
      description: playlist?['description'],
      thumbnail: playlist?['thumbnail'],
      trackCount: playlist?['songs']?.length ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class FavoriteGenresResponse {
  final List<FavoriteGenre> data;
  final int total;

  FavoriteGenresResponse({
    required this.data,
    required this.total,
  });

  factory FavoriteGenresResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteGenresResponse(
      data: (json['data'] as List?)
          ?.map((e) => FavoriteGenre.fromJson(e))
          .toList() ?? [],
      total: json['total'] ?? 0,
    );
  }
}

class FavoriteGenre {
  final String id;
  final String genreId;
  final String externalParams;
  final String name;
  final DateTime createdAt;

  FavoriteGenre({
    required this.id,
    required this.genreId,
    required this.externalParams,
    required this.name,
    required this.createdAt,
  });

  factory FavoriteGenre.fromJson(Map<String, dynamic> json) {
    final genre = json['genre'] as Map<String, dynamic>?;
    return FavoriteGenre(
      id: json['id'] ?? '',
      genreId: genre?['id'] ?? '',
      externalParams: genre?['externalParams'] ?? '',
      name: genre?['name'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
