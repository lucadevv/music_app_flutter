import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/services/local/onboarding_service.dart';
import 'package:music_app/main.dart';

/// Guard para manejar la navegación inicial basada en:
/// 1. Estado del onboarding
/// 2. Estado de autenticación
/// 3. Estado de verificación de email
class InitialRouteGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    if (kDebugMode) {
      debugPrint('InitialRouteGuard: Verificando navegación inicial');
    }

    try {
      // 1. Verificar si ya completó el onboarding
      final onboardingService = await getIt.getAsync<OnboardingService>();
      final isOnboardingCompleted = await onboardingService.isOnboardingCompleted();
      
      if (kDebugMode) {
        debugPrint('InitialRouteGuard: onboardingCompleted = $isOnboardingCompleted');
      }
      
      if (!isOnboardingCompleted) {
        // Onboarding NO completado - ir a onboarding
        if (kDebugMode) {
          debugPrint('InitialRouteGuard: Navegando a OnboardingRoute');
        }
        resolver.redirectUntil(const OnboardingRoute());
        return;
      }
      
      // 2. Verificar si el usuario está autenticado
      final authManager = await getIt.getAsync<AuthManager>();
      final refreshToken = await authManager.getCurrentRefreshToken();
      
      if (kDebugMode) {
        debugPrint('InitialRouteGuard: refreshToken = ${refreshToken != null ? "existe" : "null"}');
      }
      
      if (refreshToken != null) {
        // Usuario autenticado - verificar email
        final isEmailVerified = await authManager.isEmailVerified();
        
        if (kDebugMode) {
          debugPrint('InitialRouteGuard: isEmailVerified = $isEmailVerified');
        }
        
        if (isEmailVerified == true) {
          // Email verificado - ir a dashboard
          if (kDebugMode) {
            debugPrint('InitialRouteGuard: Navegando a DashboardShell');
          }
          resolver.redirectUntil(const DashboardShell());
        } else {
          // Email no verificado - ir a verificación
          if (kDebugMode) {
            debugPrint('InitialRouteGuard: Navegando a EmailVerificationRoute');
          }
          resolver.redirectUntil(const EmailVerificationRoute());
        }
      } else {
        // Usuario no autenticado - ir a login
        if (kDebugMode) {
          debugPrint('InitialRouteGuard: Navegando a SocialLoginRoute');
        }
        resolver.redirectUntil(const SocialLoginRoute());
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InitialRouteGuard: Error = $e');
      }
      // En caso de error, ir a onboarding
      resolver.redirectUntil(const OnboardingRoute());
    }
  }
}
