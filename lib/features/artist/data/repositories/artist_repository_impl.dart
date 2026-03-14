// ignore_for_file: deprecated_member_use_from_same_package, avoid_dynamic_calls
import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ApiServices _apiServices;

  ArtistRepositoryImpl(this._apiServices);

  @override
  Future<Artist> getArtist(String artistId) async {
    try {
      final response = await _apiServices.get('/artists/$artistId');
      final data = response is Response ? response.data : response;

      return Artist(
        id: data['id'] ?? artistId,
        name: data['name'] ?? 'Unknown Artist',
        thumbnail: data['thumbnail'],
        monthlyListeners: data['monthlyListeners'],
        description: data['description'],
      );
    } catch (e) {
      return Artist(id: artistId, name: 'Unknown Artist');
    }
  }

  @override
  Future<List<ArtistSong>> getArtistTopSongs(String artistId) async {
    try {
      final response = await _apiServices.get('/artists/$artistId/top-songs');
      final data = response is Response ? response.data : response;
      final List<dynamic> songs = data['songs'] ?? [];

      return songs
          .map(
            (song) => ArtistSong(
              videoId: song['videoId'] ?? '',
              title: song['title'] ?? 'Unknown',
              thumbnail: song['thumbnail'],
              durationSeconds: song['durationSeconds'] ?? 0,
              views: song['views'] ?? 0,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ArtistAlbum>> getArtistAlbums(String artistId) async {
    try {
      final response = await _apiServices.get('/artists/$artistId/albums');
      final data = response is Response ? response.data : response;
      final List<dynamic> albums = data['albums'] ?? [];

      return albums
          .map(
            (album) => ArtistAlbum(
              id: album['id'] ?? '',
              title: album['title'] ?? 'Unknown',
              thumbnail: album['thumbnail'],
              year: album['year'] ?? 2024,
              songCount: album['songCount'] ?? 0,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> followArtist(String artistId) async {
    await _apiServices.post('/artists/$artistId/follow');
  }

  @override
  Future<void> unfollowArtist(String artistId) async {
    await _apiServices.delete('/artists/$artistId/follow');
  }

  @override
  Future<bool> isFollowing(String artistId) async {
    try {
      final response = await _apiServices.get('/artists/$artistId/following');
      final data = response is Response ? response.data : response;
      return data['following'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
