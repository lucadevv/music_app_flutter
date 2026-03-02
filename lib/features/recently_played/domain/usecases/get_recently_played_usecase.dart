import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';
import 'package:music_app/features/recently_played/domain/repositories/recently_played_repository.dart';

/// Use case for getting recently played songs
class GetRecentlyPlayedUseCase {
  final RecentlyPlayedRepository _repository;

  GetRecentlyPlayedUseCase(this._repository);

  Future<Either<AppException, List<RecentlyPlayedSong>>> call() {
    return _repository.getRecentlyPlayed();
  }
}
