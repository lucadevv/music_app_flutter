// ignore_for_file: deprecated_member_use_from_same_package, avoid_dynamic_calls
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:music_app/core/domain/entities/artist.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ApiServices _apiServices;

  ArtistRepositoryImpl(this._apiServices);

  @override
  Future<Either<AppException, Artist>> getArtist(String artistId) async {
    try {
      final response = await _apiServices.get('/artists/$artistId');
      final data = response is Response ? response.data : response;

      return Right(
        Artist(
          id: data['id'] ?? artistId,
          name: data['name'] ?? 'Unknown Artist',
          thumbnail: data['thumbnail'],
          monthlyListeners: data['monthlyListeners'],
          description: data['description'],
        ),
      );
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<ArtistSong>>> getArtistTopSongs(
    String artistId,
  ) async {
    try {
      final response = await _apiServices.get(
        '/artists/$artistId/top-songs',
        queryParameters: {'include_stream_urls': 'true'},
      );
      final data = response is Response ? response.data : response;
      final List<dynamic> songs = data['songs'] ?? [];

      final result = songs
          .map(
            (song) => ArtistSong(
              videoId: song['videoId'] ?? '',
              title: song['title'] ?? 'Unknown',
              thumbnail: song['thumbnail'],
              durationSeconds: song['durationSeconds'] ?? 0,
              views: song['views'] ?? 0,
              streamUrl: song['streamUrl'],
            ),
          )
          .toList();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<ArtistAlbum>>> getArtistAlbums(
    String artistId,
  ) async {
    try {
      final response = await _apiServices.get('/artists/$artistId/albums');
      final data = response is Response ? response.data : response;
      final List<dynamic> albums = data['albums'] ?? [];

      final result = albums
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
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> followArtist(String artistId) async {
    try {
      await _apiServices.post('/artists/$artistId/follow');
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> unfollowArtist(String artistId) async {
    try {
      await _apiServices.delete('/artists/$artistId/follow');
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, bool>> isFollowing(String artistId) async {
    try {
      final response = await _apiServices.get('/artists/$artistId/following');
      final data = response is Response ? response.data : response;
      return Right(data['following'] ?? false);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout');
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return AuthenticationException('Unauthorized');
        } else if (statusCode == 404) {
          return ServerException('Artist not found', code: 404);
        }
        return ServerException('Server error: $statusCode');
      default:
        return UnknownException(e.message ?? 'Unknown error');
    }
  }
}
