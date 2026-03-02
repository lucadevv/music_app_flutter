import 'package:music_app/core/services/local/onboarding_service.dart';
import 'package:music_app/features/onboarding/domain/entities/onboarding_entity.dart';

/// Data source for onboarding.
/// Wraps the existing OnboardingService.
class OnboardingDataSource {
  final OnboardingService _onboardingService;

  OnboardingDataSource(this._onboardingService);

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    return _onboardingService.isOnboardingCompleted();
  }

  /// Set onboarding as completed
  Future<void> setOnboardingCompleted(bool completed) async {
    await _onboardingService.setOnboardingCompleted(completed);
  }

  /// Get onboarding pages (localization handled in presentation)
  Future<List<OnboardingPageEntity>> getOnboardingPages() async {
    // Pages are defined in presentation with localization
    return [];
  }
}
