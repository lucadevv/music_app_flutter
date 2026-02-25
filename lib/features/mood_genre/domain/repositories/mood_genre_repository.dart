import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/mood_playlists_response.dart';

/// Repositorio abstracto para operaciones de mood/genre
/// 
/// SOLID: Dependency Inversion Principle (DIP)
/// Define la interfaz que debe implementar el repositorio concreto
abstract class MoodGenreRepository {
  /// Obtiene las playlists de un mood/genre
  Future<Either<AppException, MoodPlaylistsResponse>> getMoodPlaylists(
    String params,
  );
}
