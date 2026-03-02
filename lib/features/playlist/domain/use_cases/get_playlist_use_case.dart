import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/playlist_response.dart';
import '../repositories/playlist_repository.dart';

/// Use case para obtener los datos de una playlist
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Ejecutar la lógica de negocio para obtener una playlist
class GetPlaylistUseCase {
  final PlaylistRepository _repository;

  GetPlaylistUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener una playlist
  /// 
  /// [id] - El ID de la playlist a obtener
  /// 
  /// Retorna [Either<AppException, PlaylistResponse>]
  Future<Either<AppException, PlaylistResponse>> call(String id) async {
    return _repository.getPlaylist(id);
  }
}
