import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exception.dart';
import 'package:music_app/features/dashboard/domain/entities/player_entities.dart';

/// Repository interface for Dashboard/Player feature.
abstract class DashboardRepository {
  /// Get current player state
  Future<Either<AppException, PlayerStateEntity>> getPlayerState();

  /// Get current queue
  Future<Either<AppException, QueueEntity>> getQueue();

  /// Play a song
  Future<Either<AppException, void>> playSong(Song song);

  /// Play a list of songs starting from index
  Future<Either<AppException, void>> playQueue(List<Song> songs, int startIndex);

  /// Pause playback
  Future<Either<AppException, void>> pause();

  /// Resume playback
  Future<Either<AppException, void>> resume();

  /// Stop playback
  Future<Either<AppException, void>> stop();

  /// Skip to next song
  Future<Either<AppException, void>> next();

  /// Skip to previous song
  Future<Either<AppException, void>> previous();

  /// Seek to position
  Future<Either<AppException, void>> seek(Duration position);

  /// Toggle shuffle mode
  Future<Either<AppException, void>> toggleShuffle();

  /// Toggle repeat mode
  Future<Either<AppException, void>> toggleRepeat();

  /// Set volume
  Future<Either<AppException, void>> setVolume(double volume);

  /// Add song to queue
  Future<Either<AppException, void>> addToQueue(Song song);

  /// Remove song from queue at index
  Future<Either<AppException, void>> removeFromQueue(int index);
}
