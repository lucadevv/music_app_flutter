import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
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
import 'package:music_app/main.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<OrquestadorAuthCubit>().resetRegisterState();
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
    return RegisterListeners(
      child: Scaffold(
        backgroundColor: AppColorsDark.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColorsDark.onSurface),
            onPressed: () => context.router.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
      ),
    );
  }
}
