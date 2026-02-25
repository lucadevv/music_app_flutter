import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/main.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _router = getIt<AppRouter>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final authManager = await getIt.getAsync<AuthManager>();
      final refreshToken = await authManager.getCurrentRefreshToken();
      final isEmailVerified = await authManager.isEmailVerified();

      debugPrint(
        'App._initializeApp: refreshToken = ${refreshToken != null ? "existe" : "null"}',
      );
      debugPrint(
        'App._initializeApp: isEmailVerified = $isEmailVerified (tipo: ${isEmailVerified.runtimeType})',
      );

      if (refreshToken != null) {
        // Usuario autenticado
        if (isEmailVerified != true) {
          // Email no verificado o null - ir a verificación
          debugPrint(
            'App._initializeApp: Email no verificado, navegando a EmailVerificationRoute',
          );
          _router.replaceAll([
            const DashboardShell(children: [EmailVerificationRoute()]),
          ]);
        } else {
          // Email verificado - ir a dashboard
          debugPrint(
            'App._initializeApp: Email verificado, navegando a DashboardShell',
          );
          _router.replaceAll([const DashboardShell()]);
        }
      } else {
        // Usuario no autenticado - ir a onboarding (ruta inicial)
        debugPrint(
          'App._initializeApp: No hay token, navegando a OnboardingRoute',
        );
        _router.replaceAll([const OnboardingRoute()]);
      }
    } catch (e) {
      debugPrint('App._initializeApp: Error inicializando app: $e');
      // En caso de error, ir a onboarding
      _router.replaceAll([const OnboardingRoute()]);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Music App',
      theme: AppTheme.dark(),
      routerConfig: _router.config(),
      debugShowCheckedModeBanner: false,
    );
  }
}
