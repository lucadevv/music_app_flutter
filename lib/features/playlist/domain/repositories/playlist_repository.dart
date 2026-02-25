import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/playlist_response.dart';

/// Repositorio abstracto para operaciones de playlist
/// 
/// SOLID: Dependency Inversion Principle (DIP)
/// Define la interfaz que debe implementar el repositorio concreto
abstract class PlaylistRepository {
  /// Obtiene los datos de una playlist
  Future<Either<AppException, PlaylistResponse>> getPlaylist(String id);
}
