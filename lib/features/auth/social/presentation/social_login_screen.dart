// ignore_for_file: unused_element
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/features/auth/login/presentation/cubit/login_cubit.dart';
import 'package:music_app/features/auth/login/presentation/widgets/login_listeners.dart';
import 'package:music_app/features/auth/presentation/cubit/orquestador_auth_cubit.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_blur_overlay.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_divider.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_video_background.dart';
import 'package:music_app/features/auth/presentation/widgets/social_auth_buttons.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class SocialLoginScreen extends StatefulWidget implements AutoRouteWrapper {
  const SocialLoginScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(create: (_) => getIt<LoginCubit>()),
        BlocProvider<OrquestadorAuthCubit>(
          create: (_) => getIt<OrquestadorAuthCubit>(),
        ),
      ],
      child: this,
    );
  }

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  @override
  void initState() {
    super.initState();
    // Reset auth state on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrquestadorAuthCubit>().resetLoginState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LoginListeners(
      child: Scaffold(
        backgroundColor: AppColorsDark.surface,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const AuthVideoBackground(videoPath: 'assets/video/video_login.mp4'),
            const AuthBlurOverlay(),

            // Content
            SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo App
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColorsDark.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColorsDark.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const ClipOval(
                            child: Image(
                              image: AssetImage('assets/img/logo_app.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Título
                        Text(
                          l10n.welcome,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColorsDark.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.signInToContinue,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColorsDark.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Botones sociales
                        const SocialAuthButtons(isVertical: true),
                        const SizedBox(height: 32),

                        // Divider
                        const AuthDivider(),
                        const SizedBox(height: 32),

                        // Botón iniciar sesión con email
                        OutlinedButton(
                          onPressed: () {
                            context.router.push(const LoginRoute());
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColorsDark.primary,
                            side: const BorderSide(
                              color: AppColorsDark.outline,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            l10n.login,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón registrarse
                        TextButton(
                          onPressed: () {
                            context.router.push(const RegisterRoute());
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: AppColorsDark.onSurfaceVariant,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(text: '${l10n.noAccount} '),
                                TextSpan(
                                  text: l10n.register,
                                  style: const TextStyle(
                                    color: AppColorsDark.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Language Selector
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 16,
                    child: LanguageSelector(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
