// ignore_for_file: unawaited_futures

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/services/auth/auth_service.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'widgets/widgets.dart';

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
  final bool _enableVideo = true;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _initializeVideo();
    });
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;
    try {
      _videoController = VideoPlayerController.asset(
        'assets/video/video_login.mp4',
      );
      await _videoController!.initialize();
      if (!mounted) return;
      _videoController!.setLooping(true);
      _videoController!.setVolume(0);
      await _videoController!.play();
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
          _showError(l10n.couldNotOpenEmailApp);
        }
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColorsDark.error),
      );
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
          VideoBackground(
            controller: _videoController,
            enableVideo: _enableVideo,
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
            child: VerificationContent(
              title: l10n.verifyYourEmail,
              description: l10n.verificationEmailSent,
              email: _userEmail,
              isLoadingEmail: _isLoadingEmail,
              onOpenEmail: () => _openEmailApp(l10n),
              onLogout: () => _logout(l10n),
              openEmailLabel: l10n.openMyEmail,
              logoutLabel: l10n.logout,
              additionalInfo: l10n.onceVerifiedAccess,
            ),
          ),
        ],
      ),
    );
  }
}
