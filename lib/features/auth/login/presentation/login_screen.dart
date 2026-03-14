// ignore_for_file: unawaited_futures

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/extension/sizedbox_extension.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/features/auth/login/domain/entities/login_request.dart';
import 'package:music_app/features/auth/login/presentation/cubit/login_cubit.dart'
    show LoginCubit;
import 'package:music_app/features/auth/login/presentation/notifiers/login_form_notifier.dart';
import 'package:music_app/features/auth/login/presentation/widgets/login_form_widget.dart';
import 'package:music_app/features/auth/login/presentation/widgets/login_listeners.dart';
import 'package:music_app/features/auth/presentation/cubit/orquestador_auth_cubit.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_blur_overlay.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_divider.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_video_background.dart';
import 'package:music_app/features/auth/presentation/widgets/social_auth_buttons.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class LoginScreen extends StatefulWidget implements AutoRouteWrapper {
  const LoginScreen({super.key});

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
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formNotifier = LoginFormNotifier();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
    
    context.read<OrquestadorAuthCubit>().resetLoginState();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/video/video_login.mp4');
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(0);
      await _videoController!.play();
      _videoInitialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      // Video failed to load, continue without it
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _formNotifier.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final isValid = _formNotifier.validateForm(
      email: _formNotifier.emailController.text,
      password: _formNotifier.passwordController.text,
    );

    if (!isValid) return;

    final entity = LoginRequest(
      email: _formNotifier.emailController.text.trim(),
      password: _formNotifier.passwordController.text,
    );

    context.read<LoginCubit>().login(entity);
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

            // Body
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        24.spaceh,
                        // Animated title with gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColorsDark.primary, Colors.white],
                          ).createShader(bounds),
                          child: Text(
                            l10n.loginTitle,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.enterYourCredentials,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 32),

                        LoginFormWidget(
                          formNotifier: _formNotifier,
                          onLogin: _handleLogin,
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        const AuthDivider(),
                        const SizedBox(height: 24),

                        // Social buttons with icons
                        const SocialAuthButtons(isVertical: false),
                        const SizedBox(height: 32),

                        // Register link
                        TextButton(
                          onPressed: () {
                            context.router.push(const RegisterRoute());
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
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
                    const SizedBox(height: 32),

                    // Register link
                    TextButton(
                      onPressed: () {
                        context.router.push(const RegisterRoute());
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
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
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppColorsDark.onSurface),
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
          ],
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
        ],
      ),
      ),
    );
  }
}
