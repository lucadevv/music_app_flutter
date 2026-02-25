import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../../domain/entities/mood_playlists_response.dart';
import '../../domain/repositories/mood_genre_repository.dart';
import '../data_sources/mood_genre_remote_data_source.dart';

/// Implementación del repositorio de mood/genre
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Coordinar la obtención de datos desde el data source
class MoodGenreRepositoryImpl implements MoodGenreRepository {
  final MoodGenreRemoteDataSource _remoteDataSource;

  MoodGenreRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, MoodPlaylistsResponse>> getMoodPlaylists(
    String params,
  ) async {
    return await _remoteDataSource.getMoodPlaylists(params);
  }
}
