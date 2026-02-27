import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar el estado del onboarding
class OnboardingService {
  final SharedPreferences _prefs;
  
  static const String _onboardingCompletedKey = 'onboarding_completed';
  
  OnboardingService(this._prefs);
  
  /// Verifica si el onboarding ya fue completado
  Future<bool> isOnboardingCompleted() async {
    final value = _prefs.getBool(_onboardingCompletedKey) ?? false;
    debugPrint('OnboardingService: isOnboardingCompleted = $value');
    return value;
  }
  
  /// Marca el onboarding como completado
  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_onboardingCompletedKey, true);
    debugPrint('OnboardingService: Onboarding marcado como completado');
  }
  
  /// Resetea el estado del onboarding (para testing)
  Future<void> resetOnboarding() async {
    await _prefs.remove(_onboardingCompletedKey);
    debugPrint('OnboardingService: Onboarding reseteado');
  }
}
