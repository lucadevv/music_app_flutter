import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case for completing onboarding.
class CompleteOnboardingUseCase {
  final OnboardingRepository _repository;

  CompleteOnboardingUseCase(this._repository);

  Future<Either<AppException, void>> call() {
    return _repository.setOnboardingCompleted(true);
  }
}
