import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/mood_playlists_response.dart';
import '../repositories/mood_genre_repository.dart';

/// Use case para obtener playlists de mood/genre
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Ejecutar la lógica de negocio para obtener playlists
class GetMoodPlaylistsUseCase {
  final MoodGenreRepository _repository;

  GetMoodPlaylistsUseCase(this._repository);

  /// Ejecuta el caso de uso
  /// 
  /// [params] - Parámetros del mood/genre
  Future<Either<AppException, MoodPlaylistsResponse>> call(String params) {
    return _repository.getMoodPlaylists(params);
  }
}
