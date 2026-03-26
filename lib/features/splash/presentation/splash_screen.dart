import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Pantalla de splash que sirve como punto de entrada inicial.
/// El SplashCubit decide a dónde navegar basado en:
/// 1. Estado del onboarding
/// 2. Estado de autenticación
/// 3. Estado de verificación de email
@RoutePage()
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<SplashCubit>()..initializeApp(),
      child: BlocConsumer<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state.status == SplashStatus.success &&
              state.redirectRoute != null) {
            final route = state.redirectRoute;
            if (route == '/onboarding') {
              context.router.replace(const OnboardingRoute());
            } else if (route == '/login') {
              context.router.replace(const SocialLoginRoute());
            } else {
              context.router.replace(const OnboardingRoute());
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColorsDark.surface,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.status == SplashStatus.failure)
                    Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColorsDark.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? 'Error al inicializar',
                          style: const TextStyle(color: AppColorsDark.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<SplashCubit>().initializeApp();
                          },
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        const CircularProgressIndicator(
                          color: AppColorsDark.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          state.status == SplashStatus.loading
                              ? 'Cargando...'
                              : 'Inicializando...',
                          style: const TextStyle(
                            color: AppColorsDark.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
