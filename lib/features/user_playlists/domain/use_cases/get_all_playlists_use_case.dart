import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/user_playlists/domain/entities/user_playlist_entity.dart';
import 'package:music_app/features/user_playlists/domain/repositories/user_playlists_repository.dart';

/// Use case for getting all user playlists.
class GetAllPlaylistsUseCase {
  final UserPlaylistsRepository _repository;

  GetAllPlaylistsUseCase(this._repository);

  Future<Either<AppException, List<UserPlaylistEntity>>> call() {
    return _repository.getAllPlaylists();
  }
}
