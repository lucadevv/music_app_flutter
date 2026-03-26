// ignore_for_file: unused_element
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:music_app/features/auth/domain/use_cases/oauth_sign_in_use_case.dart';
import 'package:music_app/features/auth/presentation/blocs/login_cubit.dart';
import 'package:music_app/features/auth/presentation/blocs/orquestador_auth_cubit.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_blur_overlay.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_divider.dart';
import 'package:music_app/features/auth/presentation/widgets/auth_video_background.dart';
import 'package:music_app/features/auth/presentation/widgets/login/login_listeners.dart';
import 'package:music_app/features/auth/presentation/widgets/social/widgets.dart';
import 'package:music_app/features/auth/presentation/widgets/social_auth_buttons.dart';
import 'package:music_app/main.dart';

@RoutePage()
class SocialLoginScreen extends StatefulWidget implements AutoRouteWrapper {
  const SocialLoginScreen({super.key});

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
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrquestadorAuthCubit>().resetLoginState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoginListeners(
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const AuthVideoBackground(
              videoPath: 'assets/video/video_login.mp4',
            ),
            const AuthBlurOverlay(),
            SafeArea(
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppLogo(),
                        SizedBox(height: 48),
                        WelcomeTitle(),
                        SizedBox(height: 48),
                        SocialAuthButtons(isVertical: true),
                        SizedBox(height: 32),
                        AuthDivider(),
                        SizedBox(height: 32),
                        LoginEmailButton(),
                        SizedBox(height: 24),
                        RegisterLink(),
                      ],
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 16,
                    child: LanguageSelector(
                      backgroundColor: AppColorsDark.onSurface.withValues(
                        alpha: 0.1,
                      ),
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
