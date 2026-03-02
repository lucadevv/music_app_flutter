import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/dashboard/domain/entities/player_entities.dart';
import 'package:music_app/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Use case for getting current player state
class GetPlayerStateUseCase {
  final DashboardRepository repository;

  GetPlayerStateUseCase(this.repository);

  Future<Either<AppException, PlayerStateEntity>> call() {
    return repository.getPlayerState();
  }
}

/// Use case for getting queue
class GetQueueUseCase {
  final DashboardRepository repository;

  GetQueueUseCase(this.repository);

  Future<Either<AppException, QueueEntity>> call() {
    return repository.getQueue();
  }
}

/// Use case for playing a song
class PlaySongUseCase {
  final DashboardRepository repository;

  PlaySongUseCase(this.repository);

  Future<Either<AppException, void>> call(Song song) {
    return repository.playSong(song);
  }
}

/// Use case for playing a queue
class PlayQueueUseCase {
  final DashboardRepository repository;

  PlayQueueUseCase(this.repository);

  Future<Either<AppException, void>> call(List<Song> songs, int startIndex) {
    return repository.playQueue(songs, startIndex);
  }
}

/// Use case for pausing playback
class PauseUseCase {
  final DashboardRepository repository;

  PauseUseCase(this.repository);

  Future<Either<AppException, void>> call() {
    return repository.pause();
  }
}

/// Use case for resuming playback
class ResumeUseCase {
  final DashboardRepository repository;

  ResumeUseCase(this.repository);

  Future<Either<AppException, void>> call() {
    return repository.resume();
  }
}

/// Use case for stopping playback
class StopUseCase {
  final DashboardRepository repository;

  StopUseCase(this.repository);

  Future<Either<AppException, void>> call() {
    return repository.stop();
  }
}

/// Use case for skipping to next song
class NextSongUseCase {
  final DashboardRepository repository;

  NextSongUseCase(this.repository);

  Future<Either<AppException, void>> call() {
    return repository.next();
  }
}

/// Use case for skipping to previous song
class PreviousSongUseCase {
  final DashboardRepository repository;

  PreviousSongUseCase(this.repository);

  Future<Either<AppException, void>> call() {
    return repository.previous();
  }
}

/// Use case for seeking to position
class SeekUseCase {
  final DashboardRepository repository;

  SeekUseCase(this.repository);

  Future<Either<AppException, void>> call(Duration position) {
    return repository.seek(position);
  }
}

/// Use case for toggling shuffle
class ToggleShuffleUseCase {
  final DashboardRepository repository;

  ToggleShuffleUseCase(this.repository);

  Future<Either<AppException, void>> call() {
    return repository.toggleShuffle();
  }
}

/// Use case for toggling repeat
class ToggleRepeatUseCase {
  final DashboardRepository repository;

  ToggleRepeatUseCase(this.repository);

  Future<Either<AppException, void>> call() {
    return repository.toggleRepeat();
  }
}

/// Use case for setting volume
class SetVolumeUseCase {
  final DashboardRepository repository;

  SetVolumeUseCase(this.repository);

  Future<Either<AppException, void>> call(double volume) {
    return repository.setVolume(volume);
  }
}

/// Use case for adding song to queue
class AddToQueueUseCase {
  final DashboardRepository repository;

  AddToQueueUseCase(this.repository);

  Future<Either<AppException, void>> call(Song song) {
    return repository.addToQueue(song);
  }
}

/// Use case for removing song from queue
class RemoveFromQueueUseCase {
  final DashboardRepository repository;

  RemoveFromQueueUseCase(this.repository);

  Future<Either<AppException, void>> call(int index) {
    return repository.removeFromQueue(index);
  }
}
