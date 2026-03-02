import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/offline/domain/repositories/offline_repository.dart';

/// Use case for checking if device is online.
class CheckOnlineUseCase {
  final OfflineRepository _repository;

  CheckOnlineUseCase(this._repository);

  Future<Either<AppException, bool>> call() {
    return _repository.isOnline();
  }
}
