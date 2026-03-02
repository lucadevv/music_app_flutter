import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class SocialLoginScreen extends StatelessWidget {
  const SocialLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColorsDark.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o icono
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColorsDark.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 60,
                  color: AppColorsDark.primary,
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
              _SocialButton(
                icon: Icons.g_mobiledata,
                label: l10n.continueWithGoogle,
                onPressed: () {
                  // TODO: Implement Google Sign-In (requires google_sign_in package)
                },
              ),
              const SizedBox(height: 16),
              _SocialButton(
                icon: Icons.apple,
                label: l10n.continueWithApple,
                onPressed: () {
                  // TODO: Implement Apple Sign-In (requires Sign_in_with_apple package)
                },
              ),
              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColorsDark.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.or,
                      style: const TextStyle(color: AppColorsDark.onSurfaceVariant),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColorsDark.outlineVariant)),
                ],
              ),
              const SizedBox(height: 32),

              // Botón iniciar sesión con email
              OutlinedButton(
                onPressed: () {
                  context.router.push(const LoginRoute());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColorsDark.primary,
                  side: const BorderSide(color: AppColorsDark.outline),
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
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        foregroundColor: AppColorsDark.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
