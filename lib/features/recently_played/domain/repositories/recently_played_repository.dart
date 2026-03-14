import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';

/// Repository contract for recently played
abstract class RecentlyPlayedRepository {
  Future<Either<AppException, List<RecentlyPlayedSong>>> getRecentlyPlayed();
  Future<Either<AppException, void>> recordListen(String videoId);
}
