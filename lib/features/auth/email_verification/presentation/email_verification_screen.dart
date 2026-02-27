import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/services/auth/auth_service.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = getIt<AuthService>();
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final email = await _authService.getUserEmail();
    setState(() {
      _userEmail = email;
    });
  }

  Future<void> _openEmailApp(AppLocalizations l10n) async {
    if (_userEmail == null) return;

    // Intentar abrir la aplicación de correo predeterminada
    final emailUri = Uri.parse('mailto:$_userEmail');
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Si no se puede abrir mailto, intentar abrir Gmail
        final gmailUri = Uri.parse('https://mail.google.com/mail/u/0/#inbox');
        if (await canLaunchUrl(gmailUri)) {
          await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.couldNotOpenEmailApp),
                backgroundColor: AppColorsDark.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColorsDark.error,
          ),
        );
      }
    }
  }

  Future<void> _logout(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        title: Text(
          l10n.logoutConfirmation,
          style: TextStyle(color: AppColorsDark.onSurface),
        ),
        content: Text(
          l10n.logoutTokensWarning,
          style: TextStyle(color: AppColorsDark.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppColorsDark.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.logout,
              style: TextStyle(color: AppColorsDark.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Limpiar datos de AuthService (LocalStorageService)
      await _authService.clearAuthData();

      // Limpiar datos de TokenManager (FlutterSecureStorage + SharedPreferences)
      final authManager = await getIt.getAsync<AuthManager>();
      await authManager.logout();

      // Verificar que se eliminaron correctamente
      final refreshToken = await authManager.getCurrentRefreshToken();
      final accessToken = await authManager.getCurrentAccessToken();

      if (refreshToken == null && accessToken == null) {
        // Navegar a login solo si los tokens fueron eliminados correctamente
        if (mounted) {
          context.router.replaceAll([const LoginRoute()]);
        }
      } else {
        // Si aún hay tokens, mostrar error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorClosingSession),
              backgroundColor: AppColorsDark.error,
            ),
          );
        }
      }
    }
  }

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono de verificación
              Icon(
                Icons.mark_email_unread,
                size: 80,
                color: AppColorsDark.primary,
              ),
              const SizedBox(height: 32),

              // Título
              Text(
                l10n.verifyYourEmail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColorsDark.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              Text(
                l10n.verificationEmailSent,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColorsDark.onSurfaceVariant,
                ),
              ),
              if (_userEmail != null) ...[
                const SizedBox(height: 8),
                Text(
                  _userEmail!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColorsDark.primary,
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Botón para abrir correo
              FilledButton.icon(
                onPressed: () => _openEmailApp(l10n),
                icon: const Icon(Icons.email),
                label: Text(l10n.openMyEmail),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColorsDark.primary,
                  foregroundColor: AppColorsDark.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón de salir
              OutlinedButton.icon(
                onPressed: () => _logout(l10n),
                icon: Icon(Icons.logout, color: AppColorsDark.error),
                label: Text(
                  l10n.logout,
                  style: TextStyle(color: AppColorsDark.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColorsDark.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mensaje adicional
              Text(
                l10n.onceVerifiedAccess,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColorsDark.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
