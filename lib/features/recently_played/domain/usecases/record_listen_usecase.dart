import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/recently_played/domain/repositories/recently_played_repository.dart';

/// Use case for recording a listen event
class RecordListenUseCase {
  final RecentlyPlayedRepository _repository;

  RecordListenUseCase(this._repository);

  Future<Either<AppException, void>> call(String videoId) {
    return _repository.recordListen(videoId);
  }
}