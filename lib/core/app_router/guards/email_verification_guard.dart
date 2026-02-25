import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/main.dart';

/// Guard para verificar si el email del usuario está verificado
/// Si no está verificado, redirige a la pantalla de verificación de email
class EmailVerificationGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    if (kDebugMode) {
      debugPrint(
        'EmailVerificationGuard: Iniciando verificación para ruta: ${resolver.route.name}',
      );
    }

    final authManager = await getIt.getAsync<AuthManager>();
    final isEmailVerified = await authManager.isEmailVerified();

    if (kDebugMode) {
      debugPrint(
        'EmailVerificationGuard: isEmailVerified = $isEmailVerified (tipo: ${isEmailVerified.runtimeType}), routeName = ${resolver.route.name}',
      );
    }

    // Si es null o false, el email no está verificado
    if (isEmailVerified != true) {
      if (kDebugMode) {
        debugPrint(
          'EmailVerificationGuard: Email no verificado (valor: $isEmailVerified). Redirigiendo a EmailVerificationRoute.',
        );
      }
      // Usar replaceAll para limpiar el stack y evitar que haya botón de regresar
      router.replaceAll([
        const DashboardShell(children: [EmailVerificationRoute()]),
      ]);
      resolver.next(false); // No continuar con la navegación original
    } else {
      if (kDebugMode) {
        debugPrint(
          'EmailVerificationGuard: Email verificado. Permitiendo acceso a ${resolver.route.name}.',
        );
      }
      resolver.next(true);
    }
  }
}
