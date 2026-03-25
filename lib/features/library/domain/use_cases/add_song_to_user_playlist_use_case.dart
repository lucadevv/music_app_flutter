import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to add a song to a user playlist.
class AddSongToUserPlaylistUseCase {
  final LibraryRepository _repository;

  AddSongToUserPlaylistUseCase(this._repository);

  /// Execute the use case
  /// [playlistId] - The ID of the playlist
  /// [videoId] - The YouTube video ID
  /// [title] - Song title
  /// [artist] - Artist name
  /// [thumbnail] - Song thumbnail URL
  /// [duration] - Song duration in seconds
  Future<Either<AppException, UserPlaylistDetail>> call(
    String playlistId, {
    required String videoId,
    String? title,
    String? artist,
    String? thumbnail,
    int? duration,
  }) async {
    return _repository.addSongToUserPlaylist(
      playlistId,
      videoId: videoId,
      title: title,
      artist: artist,
      thumbnail: thumbnail,
      duration: duration,
    );
  }
}
