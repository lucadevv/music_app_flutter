// ignore_for_file: deprecated_member_use_from_same_package, avoid_dynamic_calls
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/domain/repositories/album_repository.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final ApiServices _apiServices;

  AlbumRepositoryImpl(this._apiServices);

  @override
  Future<Either<AppException, Album>> getAlbum(String albumId) async {
    try {
      final response = await _apiServices.get('/albums/$albumId');
      final data = response is Response ? response.data : response;

      return Right(
        Album(
          id: data['id'] ?? albumId,
          title: data['title'] ?? 'Unknown Album',
          thumbnail: data['thumbnail'],
          artistName: data['artistName'],
          artistId: data['artistId'],
          year: data['year'] ?? 2024,
        ),
      );
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<AlbumSong>>> getAlbumSongs(
    String albumId,
  ) async {
    try {
      final response = await _apiServices.get(
        '/albums/$albumId/songs',
        queryParameters: {'include_stream_urls': 'true'},
      );
      final data = response is Response ? response.data : response;
      final List<dynamic> songs = data['songs'] ?? [];

      final result = songs
          .map(
            (song) => AlbumSong(
              videoId: song['videoId'] ?? '',
              title: song['title'] ?? 'Unknown',
              thumbnail: song['thumbnail'],
              durationSeconds: song['durationSeconds'] ?? 0,
              trackNumber: song['trackNumber'] ?? 0,
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
  Future<Either<AppException, void>> likeAlbum(String albumId) async {
    try {
      await _apiServices.post('/albums/$albumId/like');
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> unlikeAlbum(String albumId) async {
    try {
      await _apiServices.delete('/albums/$albumId/like');
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, bool>> isLiked(String albumId) async {
    try {
      final response = await _apiServices.get('/albums/$albumId/liked');
      final data = response is Response ? response.data : response;
      return Right(data['liked'] ?? false);
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
        return const NetworkException('Connection timeout');
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return const AuthenticationException('Unauthorized');
        } else if (statusCode == 404) {
          return const ServerException('Album not found', code: 404);
        }
        return ServerException('Server error: $statusCode');
      default:
        return UnknownException(e.message ?? 'Unknown error');
    }
  }
}
