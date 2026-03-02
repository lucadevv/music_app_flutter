import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/services/local/onboarding_service.dart';
import 'package:music_app/features/splash/domain/entities/splash_entity.dart';

/// Data source for splash initialization.
/// Combines AuthManager and OnboardingService.
class SplashDataSource {
  final AuthManager _authManager;
  final OnboardingService _onboardingService;

  SplashDataSource(this._authManager, this._onboardingService);

  /// Initialize app and determine redirect route
  Future<SplashEntity> initializeApp() async {
    final isOnboardingCompleted = await _onboardingService.isOnboardingCompleted();
    final isAuthenticated = await _authManager.isUserLoggedIn();
    
    String? redirectRoute;
    if (!isOnboardingCompleted) {
      redirectRoute = '/onboarding';
    } else if (!isAuthenticated) {
      redirectRoute = '/login';
    } else {
      // Check if email is verified
      // For now, always go to home
      redirectRoute = '/home';
    }

    return SplashEntity(
      isOnboardingCompleted: isOnboardingCompleted,
      isAuthenticated: isAuthenticated,
      redirectRoute: redirectRoute,
    );
  }
}
