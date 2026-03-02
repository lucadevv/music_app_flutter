import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/profile/domain/entities/library_stats_entity.dart';
import 'package:music_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case for getting library statistics.
class GetLibraryStatsUseCase {
  final ProfileRepository _repository;

  GetLibraryStatsUseCase(this._repository);

  Future<Either<AppException, LibraryStatsEntity>> call() {
    return _repository.getLibraryStats();
  }
}
