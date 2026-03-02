import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/domain/repositories/album_repository.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final ApiServices _apiServices;

  AlbumRepositoryImpl(this._apiServices);

  @override
  Future<Album> getAlbum(String albumId) async {
    try {
      final response = await _apiServices.get('/albums/$albumId');
      final data = response is Response ? response.data : response;

      return Album(
        id: data['id'] ?? albumId,
        title: data['title'] ?? 'Unknown Album',
        thumbnail: data['thumbnail'],
        artistName: data['artistName'],
        artistId: data['artistId'],
        year: data['year'] ?? 2024,
      );
    } catch (e) {
      return Album(id: albumId, title: 'Unknown Album');
    }
  }

  @override
  Future<List<AlbumSong>> getAlbumSongs(String albumId) async {
    try {
      final response = await _apiServices.get('/albums/$albumId/songs');
      final data = response is Response ? response.data : response;
      final List<dynamic> songs = data['songs'] ?? [];

      return songs
          .map(
            (song) => AlbumSong(
              videoId: song['videoId'] ?? '',
              title: song['title'] ?? 'Unknown',
              thumbnail: song['thumbnail'],
              durationSeconds: song['durationSeconds'] ?? 0,
              trackNumber: song['trackNumber'] ?? 0,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> likeAlbum(String albumId) async {
    await _apiServices.post('/albums/$albumId/like');
  }

  @override
  Future<void> unlikeAlbum(String albumId) async {
    await _apiServices.delete('/albums/$albumId/like');
  }

  @override
  Future<bool> isLiked(String albumId) async {
    try {
      final response = await _apiServices.get('/albums/$albumId/liked');
      final data = response is Response ? response.data : response;
      return data['liked'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
