import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/extension/sizedbox_extension.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/features/auth/login/domain/entities/login_request.dart';
import 'package:music_app/features/auth/login/presentation/cubit/login_cubit.dart'
    show LoginCubit, LoginStatus, LoginState;
import 'package:music_app/features/auth/login/presentation/notifiers/login_form_notifier.dart';
import 'package:music_app/features/auth/login/presentation/widgets/login_listeners.dart';
import 'package:music_app/features/auth/presentation/cubit/orquestador_auth_cubit.dart';
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
  bool _obscurePassword = true;
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _enableVideo = true; // Enable video
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Delay video init to avoid platform connection issues
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _initializeVideo();
    });
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
            // Video Background (disabled to avoid platform issues)
            if (_enableVideo && _videoInitialized && _videoController != null && _videoController!.value.isInitialized)
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

                    // Email field
                    ListenableBuilder(
                      listenable: _formNotifier,
                      builder: (context, _) {
                        return TextFormField(
                          controller: _formNotifier.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: l10n.emailAddress,
                            hintText: l10n.emailHint,
                            prefixIcon: const Icon(
                              Icons.email_rounded,
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
                            errorText: _formNotifier.emailError,
                          ),
                          style: const TextStyle(color: AppColorsDark.onSurface),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    ListenableBuilder(
                      listenable: _formNotifier,
                      builder: (context, _) {
                        return TextFormField(
                          controller: _formNotifier.passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: l10n.passwordLabel,
                            hintText: l10n.passwordHint,
                            prefixIcon: const Icon(
                              Icons.lock_rounded,
                              color: AppColorsDark.primary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: AppColorsDark.onSurfaceVariant,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
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
                            errorText: _formNotifier.passwordError,
                          ),
                          style: const TextStyle(color: AppColorsDark.onSurface),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.router.push(const ForgotPasswordRoute());
                        },
                        child: Text(
                          l10n.forgotYourPassword,
                          style: const TextStyle(
                            color: AppColorsDark.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login button with gradient
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) {
                        final isLoading = state.status == LoginStatus.loading;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isLoading ? null : const LinearGradient(
                              colors: [AppColorsDark.primary, Color(0xFF7C4DFF)],
                            ),
                          ),
                          child: FilledButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              disabledBackgroundColor: AppColorsDark.onSurfaceVariant,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    l10n.loginButton,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColorsDark.outlineVariant),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.or,
                            style: const TextStyle(
                              color: AppColorsDark.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppColorsDark.outlineVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social buttons with icons
                    Row(
                      children: [
                        Expanded(
                          child: BlocBuilder<LoginCubit, LoginState>(
                            builder: (context, state) {
                              final isLoading = state.status == LoginStatus.loading;
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.1),
                                      Colors.white.withValues(alpha: 0.05),
                                    ],
                                  ),
                                ),
                                child: OutlinedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          context
                                              .read<LoginCubit>()
                                              .signInWithGoogle();
                                        },
                                  icon: const Icon(
                                    Icons.g_mobiledata,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  label: Text(
                                    l10n.google,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: BlocBuilder<LoginCubit, LoginState>(
                            builder: (context, state) {
                              final isLoading = state.status == LoginStatus.loading;
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.1),
                                      Colors.white.withValues(alpha: 0.05),
                                    ],
                                  ),
                                ),
                                child: OutlinedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          context
                                              .read<LoginCubit>()
                                              .signInWithApple();
                                        },
                                  icon: const Icon(
                                    Icons.apple,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  label: Text(
                                    l10n.apple,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              );
                            },
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
        ],
      ),
      ),
    );
  }
}
