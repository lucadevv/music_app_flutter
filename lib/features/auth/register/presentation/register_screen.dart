import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/extension/sizedbox_extension.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/features/auth/presentation/cubit/orquestador_auth_cubit.dart';
import 'package:music_app/features/auth/register/domain/entities/register_request.dart';
import 'package:music_app/features/auth/register/presentation/cubit/register_cubit.dart';

import 'package:music_app/features/auth/register/presentation/notifiers/register_form_notifier.dart';
import 'package:music_app/features/auth/register/presentation/widgets/login_link.dart';
import 'package:music_app/features/auth/register/presentation/widgets/register_button.dart';
import 'package:music_app/features/auth/register/presentation/widgets/register_form_fields.dart';
import 'package:music_app/features/auth/register/presentation/widgets/register_header.dart';
import 'package:music_app/features/auth/register/presentation/widgets/register_listeners.dart';
import 'package:music_app/features/auth/register/presentation/widgets/social_buttons.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget implements AutoRouteWrapper {
  const RegisterScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterCubit>(create: (_) => getIt<RegisterCubit>()),
        BlocProvider<OrquestadorAuthCubit>(
          create: (_) => getIt<OrquestadorAuthCubit>(),
        ),
      ],
      child: this,
    );
  }

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _obscurePassword = ValueNotifier<bool>(true);
  final _obscureConfirmPassword = ValueNotifier<bool>(true);
  final _formNotifier = RegisterFormNotifier();
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
    context.read<OrquestadorAuthCubit>().resetRegisterState();
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    _formNotifier.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final isValid = _formNotifier.validateForm(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!isValid) return;

    // Crear la entidad y pasarla al cubit
    final entity = RegisterRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    context.read<RegisterCubit>().register(entity);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return RegisterListeners(
      child: Scaffold(
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

          

            // Body
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      32.spaceh,
                      const RegisterHeader(),
                      
                      RegisterFormFields(
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        formNotifier: _formNotifier,
                        obscurePassword: _obscurePassword,
                        obscureConfirmPassword: _obscureConfirmPassword,
                      ),
                      const SizedBox(height: 32),
                      RegisterButton(onPressed: _handleRegister),
                      const SizedBox(height: 24),
                      const SocialButtons(),
                      const SizedBox(height: 24),
                      const LoginLink(),
                    ],
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
                        onPressed: () {
                          context.router.pop();
                       
                        },
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
