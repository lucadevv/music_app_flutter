import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service para manejar el estado del onboarding
class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  
  final SharedPreferences _prefs;
  
  OnboardingService(this._prefs);
  
  /// Verifica si el onboarding ya fue completado
  Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }
  
  /// Marca el onboarding como completado
  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_onboardingCompletedKey, value);
    if (kDebugMode) {
      debugPrint('OnboardingService: onboarding completado = $value');
    }
  }
}
