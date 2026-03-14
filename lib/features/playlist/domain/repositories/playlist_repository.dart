import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/playlist_response.dart';

/// Repositorio abstracto para operaciones de playlist
///
/// SOLID: Dependency Inversion Principle (DIP)
/// Define la interfaz que debe implementar el repositorio concreto
abstract class PlaylistRepository {
  /// Obtiene los datos de una playlist
  /// Soporta paginación con startIndex y limit (default 10)
  Future<Either<AppException, PlaylistResponse>> getPlaylist(
    String id, {
    int startIndex = 0,
    int limit = 10,
  });
}
