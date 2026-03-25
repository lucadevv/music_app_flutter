import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/user_playlists/domain/entities/user_playlist_entity.dart';
import 'package:music_app/features/user_playlists/domain/repositories/user_playlists_repository.dart';

/// Use case for getting user playlists.
class GetUserPlaylistsUseCase {
  final UserPlaylistsRepository _repository;

  GetUserPlaylistsUseCase(this._repository);

  /// Executes the use case to get all user playlists.
  ///
  /// Returns:
  ///   A Future containing Either of AppException or List of UserPlaylistEntity representing the result
  Future<Either<AppException, List<UserPlaylistEntity>>> call() {
    return _repository.getAllPlaylists();
  }
}
