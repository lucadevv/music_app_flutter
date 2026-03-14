// ignore_for_file: unawaited_futures
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/services/auth/auth_service.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

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
  bool _isLoadingEmail = true;
  VideoPlayerController? _videoController;
//   bool _videoInitialized = false;
  final bool _enableVideo = true;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    // Delay video init to avoid platform connection issues
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _initializeVideo();
    });
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;
    try {
      _videoController = VideoPlayerController.asset('assets/video/video_login.mp4');
      await _videoController!.initialize();
      if (!mounted) return;
      _videoController!.setLooping(true);
      _videoController!.setVolume(0);
      await _videoController!.play();
//       _videoInitialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      // Video failed to load
    }
  }

  Future<void> _loadUserEmail() async {
    final email = await _authService.getUserEmail();
    if (mounted) {
      setState(() {
        _userEmail = email;
        _isLoadingEmail = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _openEmailApp(AppLocalizations l10n) async {
    if (_userEmail == null) return;

    final emailUri = Uri.parse('mailto:$_userEmail');
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
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
          style: const TextStyle(color: AppColorsDark.onSurface),
        ),
        content: Text(
          l10n.logoutTokensWarning,
          style: const TextStyle(color: AppColorsDark.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColorsDark.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.logout,
              style: const TextStyle(color: AppColorsDark.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.clearAuthData();
      if (mounted) {
        await context.router.replaceAll([const LoginRoute()]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColorsDark.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Background
          if (_enableVideo && _videoController != null && _videoController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          
          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: AppColorsDark.surface.withValues(alpha: 0.7),
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

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icono de verificación
                  const Icon(
                    Icons.mark_email_unread,
                    size: 80,
                    color: AppColorsDark.primary,
                  ),
                  const SizedBox(height: 32),

                  // Título
                  Text(
                    l10n.verifyYourEmail,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColorsDark.onSurfaceVariant,
                    ),
                  ),
                  if (_userEmail != null && !_isLoadingEmail) ...[
                    const SizedBox(height: 8),
                    Text(
                      _userEmail!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                    icon: const Icon(Icons.logout, color: AppColorsDark.error),
                    label: Text(
                      l10n.logout,
                      style: const TextStyle(color: AppColorsDark.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColorsDark.error),
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColorsDark.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
