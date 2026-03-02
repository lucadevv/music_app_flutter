import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../../domain/entities/playlist_response.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../data_sources/playlist_remote_data_source.dart';

/// Implementación del repositorio de playlist
///
/// SOLID: Dependency Inversion Principle (DIP)
/// Implementa la interfaz definida en PlaylistRepository
class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistRemoteDataSource _remoteDataSource;

  PlaylistRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, PlaylistResponse>> getPlaylist(String id) async {
    return _remoteDataSource.getPlaylist(id);
  }
}
