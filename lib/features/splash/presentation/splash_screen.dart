import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Pantalla de splash que sirve como punto de entrada inicial.
/// El InitialRouteGuard decide a dónde navegar basado en:
/// 1. Estado del onboarding
/// 2. Estado de autenticación
/// 3. Estado de verificación de email
@RoutePage()
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] SplashScreen: building');
    return const Scaffold(
      backgroundColor: AppColorsDark.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o indicador de carga
             CircularProgressIndicator(
              color: AppColorsDark.primary,
            ),
             SizedBox(height: 24),
            Text(
              'Cargando...',
              style: TextStyle(
                color: AppColorsDark.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
