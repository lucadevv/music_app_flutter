// ignore_for_file: unawaited_futures
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/auth/presentation/cubit/orquestador_auth_cubit.dart';
import 'package:music_app/features/auth/register/domain/entities/register_request.dart';
import 'package:music_app/features/auth/register/domain/use_cases/register_use_case.dart';
import 'package:music_app/features/auth/register/presentation/cubit/register_cubit.dart';
import 'package:music_app/features/auth/register/presentation/notifiers/register_form_notifier.dart';
import 'package:music_app/features/auth/register/presentation/widgets/register_body_content.dart';
import 'package:music_app/features/auth/register/presentation/widgets/register_listeners.dart';
import 'package:music_app/features/auth/register/presentation/widgets/register_top_bar.dart';
import 'package:music_app/features/auth/register/presentation/widgets/video_background.dart';
import 'package:music_app/main.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget implements AutoRouteWrapper {
  const RegisterScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterCubit>(
          create: (_) =>
              RegisterCubit(registerUseCase: getIt<RegisterUseCase>()),
        ),
        BlocProvider<OrquestadorAuthCubit>(
          create: (_) => OrquestadorAuthCubit(),
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
  final bool _enableVideo = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _initializeVideo();
    });
    context.read<OrquestadorAuthCubit>().resetRegisterState();
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
    return RegisterListeners(
      child: Scaffold(
        backgroundColor: AppColorsDark.surface,
        body: Stack(
          fit: StackFit.expand,
          children: [
            VideoBackground(
              videoController: _videoController,
              enableVideo: _enableVideo,
            ),
            SafeArea(
              child: RegisterBodyContent(
                formKey: _formKey,
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                obscurePassword: _obscurePassword,
                obscureConfirmPassword: _obscureConfirmPassword,
                formNotifier: _formNotifier,
                onRegister: _handleRegister,
              ),
            ),
            const RegisterTopBar(),
          ],
        ),
      ),
    );
  }
}
