import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/core/app_router/app_routes.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/main.dart';

/// Guard para proteger rutas privadas
/// Verifica si el usuario está autenticado antes de permitir el acceso
class AuthGuard extends AutoRouteGuard {
  final AppRouter _appRouter;
  StreamSubscription<AuthStatus>? _authStatusSubscription;
  bool _listenerSetup = false;

  AuthGuard() : _appRouter = getIt<AppRouter>();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    if (kDebugMode) {
      debugPrint(
        'AuthGuard: Verificando autenticación para ruta: ${resolver.route.name}',
      );
    }

    // Obtener AuthManager de forma async
    final authManager = await getIt.getAsync<AuthManager>();

    // Configurar listener reactivo solo una vez
    if (!_listenerSetup) {
      _setupAuthListener(authManager);
      _listenerSetup = true;
    }

    final refreshToken = await authManager.getCurrentRefreshToken();

    if (kDebugMode) {
      debugPrint(
        'AuthGuard: refreshToken = ${refreshToken != null ? "existe" : "null"}',
      );
    }

    if (refreshToken != null) {
      resolver.next(true);
    } else {
      if (kDebugMode) {
        debugPrint('AuthGuard: No hay token, redirigiendo a LoginRoute');
      }
      resolver.redirectUntil(const LoginRoute());
    }
  }

  void _setupAuthListener(AuthManager authManager) {
    _authStatusSubscription?.cancel();
    _authStatusSubscription = authManager.authStatusStream.listen((status) {
      if (status == AuthStatus.unauthenticated) {
        _appRouter.replaceAll([const SocialLoginRoute()]);
      }
    });
  }

  void dispose() {
    _authStatusSubscription?.cancel();
  }
}
