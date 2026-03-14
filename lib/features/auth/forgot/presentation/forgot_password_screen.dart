import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

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
  bool _videoInitialized = false;
  bool _enableVideo = true;

  @override
  void initState() {
    super.initState();
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
      _videoInitialized = true;
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
                      icon: const Icon(Icons.arrow_back, color: AppColorsDark.onSurface),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColorsDark.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 50,
                    color: AppColorsDark.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Título
                Text(
                  _emailSent ? l10n.emailSent : l10n.recoverPassword,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColorsDark.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _emailSent
                      ? l10n.checkInbox
                      : l10n.enterEmailInstructions,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColorsDark.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                if (!_emailSent) ...[
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      hintText: l10n.emailPlaceholder,
                      prefixIcon: const Icon(
                        Icons.email,
                        color: AppColorsDark.primary,
                      ),
                      filled: true,
                      fillColor: AppColorsDark.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: const TextStyle(
                        color: AppColorsDark.onSurfaceVariant,
                      ),
                      hintStyle: const TextStyle(
                        color: AppColorsDark.onSurfaceVariant,
                      ),
                    ),
                    style: const TextStyle(color: AppColorsDark.onSurface),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterEmail;
                      }
                      if (!value.contains('@')) {
                        return l10n.enterValidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Send button
                  FilledButton(
                    onPressed: _sendResetEmail,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColorsDark.primary,
                      foregroundColor: AppColorsDark.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      l10n.sendInstructions,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  // Success icon
                  const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppColorsDark.primary,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      context.router.push(const LoginRoute());
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColorsDark.primary,
                      foregroundColor: AppColorsDark.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      l10n.backToLogin,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Back to login link
                TextButton(
                  onPressed: () {
                    context.router.push(const LoginRoute());
                  },
                  child: Text(
                    l10n.backToLogin,
                    style: const TextStyle(
                      color: AppColorsDark.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),),),
        ],
      ),
    );
  }
}
