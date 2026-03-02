import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/onboarding/domain/entities/onboarding_entity.dart';

/// Repository interface for onboarding operations.
abstract class OnboardingRepository {
  /// Check if onboarding is completed
  Future<Either<AppException, bool>> isOnboardingCompleted();

  /// Set onboarding as completed
  Future<Either<AppException, void>> setOnboardingCompleted(bool completed);

  /// Get onboarding pages
  Future<Either<AppException, List<OnboardingPageEntity>>> getOnboardingPages();
}
