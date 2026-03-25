import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to get a single user playlist by ID.
class GetUserPlaylistUseCase {
  final LibraryRepository _repository;

  GetUserPlaylistUseCase(this._repository);

  /// Execute the use case
  /// [playlistId] - The ID of the playlist to retrieve
  Future<Either<AppException, UserPlaylistDetail>> call(
    String playlistId,
  ) async {
    return _repository.getUserPlaylist(playlistId);
  }
}
