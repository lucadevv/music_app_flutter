import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/features/auth/login/presentation/cubit/login_cubit.dart';
import 'package:music_app/features/auth/login/presentation/widgets/login_listeners.dart';
import 'package:music_app/features/auth/presentation/cubit/orquestador_auth_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';
import 'package:video_player/video_player.dart';

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

class _SocialLoginScreenState extends State<SocialLoginScreen>
    with AutoRouteAware, WidgetsBindingObserver {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  final bool _enableVideo = true;
  AutoRouteObserver? _observer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final observers = RouterScope.of(context).navigatorObservers;
    _observer = observers.whereType<AutoRouteObserver>().firstOrNull;
    _observer?.subscribe(this, context.routeData);
    // Delay video init to avoid platform connection issues
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _initializeVideo();
    });
    // Reset auth state on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrquestadorAuthCubit>().resetLoginState();
      }
    });
  }

  void _onRouteChange() {
    // Check if this screen is currently visible after navigation
    if (mounted) {
      final currentRoute = AutoRouter.of(context).current.name;
      // If we're on this screen and video is initialized, play
      if (currentRoute == 'SocialLoginRoute' && _videoInitialized) {
        _videoController?.play();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause when app goes to background
    if (state == AppLifecycleState.paused) {
      _videoController?.pause();
    }
    // Resume when app comes back to foreground
    else if (state == AppLifecycleState.resumed) {
      _videoController?.play();
    }
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;
    try {
      _videoController = VideoPlayerController.asset(
        'assets/video/video_login.mp4',
      );
      await _videoController!.initialize();
      if (!mounted) return;
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0);
      await _videoController!.play();
      _videoInitialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  @override
  void deactivate() {
    // Pause video when leaving this screen
    _videoController?.pause();
    super.deactivate();
  }

  @override
  void didPopNext() {
    _videoController?.play();
    super.didPopNext();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _observer?.unsubscribe(this);
    _videoController?.dispose();
    super.dispose();
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
            // Video Background (only if initialized)
            if (_enableVideo &&
                _videoInitialized &&
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

            // Blur overlay (always show)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: AppColorsDark.surface.withValues(alpha: 0.7),
              ),
            ),

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
                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            final isLoading = state.isLoadingFor(
                              OAuthProviderType.google,
                            );
                            return _SocialButton(
                              icon: Icons.g_mobiledata,
                              label: l10n.continueWithGoogle,
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context
                                          .read<LoginCubit>()
                                          .signInWithGoogle();
                                    },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            final isLoading = state.isLoadingFor(
                              OAuthProviderType.apple,
                            );
                            return _SocialButton(
                              icon: Icons.apple,
                              label: l10n.continueWithApple,
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context
                                          .read<LoginCubit>()
                                          .signInWithApple();
                                    },
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Divider
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColorsDark.outlineVariant,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                l10n.or,
                                style: const TextStyle(
                                  color: AppColorsDark.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: AppColorsDark.outlineVariant,
                              ),
                            ),
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

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = onPressed == null;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        foregroundColor: AppColorsDark.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColorsDark.onSurface,
                ),
              ),
            )
          : Row(
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
