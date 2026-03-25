import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case for adding a song to a playlist.
class AddToPlaylistUseCase {
  final LibraryRepository _repository;

  AddToPlaylistUseCase(this._repository);

  /// Executes the use case to add a song to a playlist.
  ///
  /// Parameters:
  ///   - playlistId: The ID of the playlist to add the song to
  ///   - videoId: The YouTube video ID of the song
  ///   - title: The title of the song
  ///   - artist: The artist of the song
  ///   - thumbnail: Optional thumbnail URL for the song
  ///   - duration: Optional duration in seconds of the song
  ///
  /// Returns:
  ///   A Future containing Either of AppException or void representing the result
  Future<Either<AppException, void>> call({
    required String playlistId,
    required String videoId,
    required String title,
    required String artist,
    String? thumbnail,
    int? duration,
  }) async {
    try {
      await _repository.addSongToUserPlaylist(
        playlistId,
        videoId: videoId,
        title: title,
        artist: artist,
        thumbnail: thumbnail,
        duration: duration,
      );
      return const Right(null);
    } catch (e) {
      return Left(UnknownException('Failed to add song to playlist: $e'));
    }
  }
}
