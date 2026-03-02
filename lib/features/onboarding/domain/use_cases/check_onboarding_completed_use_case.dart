import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case for checking if onboarding is completed.
class CheckOnboardingCompletedUseCase {
  final OnboardingRepository _repository;

  CheckOnboardingCompletedUseCase(this._repository);

  Future<Either<AppException, bool>> call() {
    return _repository.isOnboardingCompleted();
  }
}
