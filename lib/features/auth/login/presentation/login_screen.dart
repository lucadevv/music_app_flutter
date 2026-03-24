// ignore_for_file: unawaited_futures

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/extension/sizedbox_extension.dart';
import 'package:music_app/features/auth/login/domain/entities/login_request.dart';
import 'package:music_app/features/auth/login/domain/use_cases/login_use_case.dart';
import 'package:music_app/features/auth/login/domain/use_cases/oauth_sign_in_use_case.dart';
import 'package:music_app/features/auth/login/presentation/cubit/login_cubit.dart'
    show LoginCubit;
import 'package:music_app/features/auth/login/presentation/notifiers/login_form_notifier.dart';
import 'package:music_app/features/auth/login/presentation/widgets/atoms/login_app_bar.dart';
import 'package:music_app/features/auth/login/presentation/widgets/atoms/login_title.dart';
import 'package:music_app/features/auth/login/presentation/widgets/atoms/register_link.dart';
import 'package:music_app/features/auth/login/presentation/widgets/login_form_widget.dart';
import 'package:music_app/features/auth/login/presentation/widgets/login_listeners.dart';
import 'package:music_app/features/auth/presentation/cubit/orquestador_auth_cubit.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_blur_overlay.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_video_background.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_divider.dart';
import 'package:music_app/features/auth/presentation/widgets/social_auth_buttons.dart';
import 'package:music_app/main.dart';

@RoutePage()
class LoginScreen extends StatefulWidget implements AutoRouteWrapper {
  const LoginScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (_) => LoginCubit(
            loginUseCase: getIt<LoginUseCase>(),
            googleSignInUseCase: getIt<GoogleSignInUseCase>(),
            appleSignInUseCase: getIt<AppleSignInUseCase>(),
          ),
        ),
        BlocProvider<OrquestadorAuthCubit>(
          create: (_) => OrquestadorAuthCubit(),
        ),
      ],
      child: this,
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
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
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();

    context.read<OrquestadorAuthCubit>().resetLoginState();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _formNotifier.dispose();
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
    return LoginListeners(
      child: Scaffold(
        backgroundColor: AppColorsDark.surface,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const AuthVideoBackground(
              videoPath: 'assets/video/video_login.mp4',
            ),
            const AuthBlurOverlay(),

            // Animated body
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _LoginBody(
                  formNotifier: _formNotifier,
                  onLogin: _handleLogin,
                ),
              ),
            ),

            // App bar
            const LoginAppBar(),
          ],
        ),
      ),
    );
  }
}

/// Organism: Login body containing header, form, divider, social buttons, register link
class _LoginBody extends StatelessWidget {
  final LoginFormNotifier formNotifier;
  final VoidCallback onLogin;

  const _LoginBody({required this.formNotifier, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            24.spaceh,
            const LoginTitle(),
            const SizedBox(height: 32),

            LoginFormWidget(formNotifier: formNotifier, onLogin: onLogin),
            const SizedBox(height: 24),

            const AuthDivider(),
            const SizedBox(height: 24),

            const SocialAuthButtons(isVertical: false),
            const SizedBox(height: 32),

            const RegisterLink(),
          ],
        ),
      ),
    );
  }
}
