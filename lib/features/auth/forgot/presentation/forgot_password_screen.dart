// ignore_for_file: unawaited_futures
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

import 'widgets/widgets.dart';

@RoutePage()
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;
  VideoPlayerController? _videoController;
  final bool _enableVideo = true;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _emailController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _sendResetEmail() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _emailSent = true;
      });
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
          if (_enableVideo &&
              _videoController != null &&
              _videoController!.value.isInitialized)
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

          // AppBar transparente
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColorsDark.onSurface,
                      ),
                      onPressed: () => context.router.pop(),
                    ),
                    LanguageSelector(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body
          SafeArea(
            child: ForgotPasswordContent(
              emailSent: _emailSent,
              title: _emailSent ? l10n.emailSent : l10n.recoverPassword,
              description: _emailSent
                  ? l10n.checkInbox
                  : l10n.enterEmailInstructions,
              sendButtonLabel: l10n.sendInstructions,
              backToLoginLabel: l10n.backToLogin,
              formKey: _formKey,
              emailController: _emailController,
              onSendPressed: _sendResetEmail,
            ),
          ),
        ],
      ),
    );
  }
}
