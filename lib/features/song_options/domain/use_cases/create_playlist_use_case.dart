import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/user_playlists/domain/entities/user_playlist_entity.dart';
import 'package:music_app/features/user_playlists/domain/repositories/user_playlists_repository.dart';

/// Use case for creating a playlist.
class CreatePlaylistUseCase {
  final UserPlaylistsRepository _repository;

  CreatePlaylistUseCase(this._repository);

  /// Executes the use case to create a playlist.
  ///
  /// Parameters:
  ///   - name: The name of the playlist to create
  ///
  /// Returns:
  ///   A Future containing Either of AppException or UserPlaylistEntity representing the result
  Future<Either<AppException, UserPlaylistEntity>> call({
    required String name,
  }) async {
    return _repository.createPlaylist(name);
  }
}
