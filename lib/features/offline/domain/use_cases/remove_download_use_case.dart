import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/offline/domain/repositories/offline_repository.dart';

/// Use case for removing a downloaded song.
class RemoveDownloadUseCase {
  final OfflineRepository _repository;

  RemoveDownloadUseCase(this._repository);

  Future<Either<AppException, void>> call(String videoId) {
    return _repository.removeDownload(videoId);
  }
}
