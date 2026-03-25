import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';

/// Use case to get the library summary (counts of favorites).
class GetLibrarySummaryUseCase {
  final LibraryRepository _repository;

  GetLibrarySummaryUseCase(this._repository);

  /// Execute the use case
  Future<Either<AppException, LibrarySummaryEntity>> call() async {
    return _repository.getSummary();
  }
}
