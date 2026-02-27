import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/auth/login/domain/entities/login_request.dart';
import 'package:music_app/features/auth/login/presentation/cubit/login_cubit.dart'
    show LoginCubit, LoginStatus, LoginState;
import 'package:music_app/features/auth/login/presentation/notifiers/login_form_notifier.dart';
import 'package:music_app/features/auth/login/presentation/widgets/login_listeners.dart';
import 'package:music_app/features/auth/presentation/cubit/orquestador_auth_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

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

class _LoginScreenState extends State<LoginScreen> {
  final _formNotifier = LoginFormNotifier();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Reiniciar estado de login al entrar a la pantalla
    context.read<OrquestadorAuthCubit>().resetLoginState();
  }

  @override
  void dispose() {
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
    final l10n = AppLocalizations.of(context)!;
    
    return LoginListeners(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                Text(
                  l10n.loginTitle,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColorsDark.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.enterYourCredentials,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColorsDark.onSurfaceVariant,
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
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColorsDark.primary,
                        ),
                        filled: true,
                        fillColor: AppColorsDark.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        labelStyle: TextStyle(
                          color: AppColorsDark.onSurfaceVariant,
                        ),
                        hintStyle: TextStyle(
                          color: AppColorsDark.onSurfaceVariant,
                        ),
                        errorText: _formNotifier.emailError,
                      ),
                      style: TextStyle(color: AppColorsDark.onSurface),
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
                        prefixIcon: Icon(
                          Icons.lock,
                          color: AppColorsDark.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
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
                        labelStyle: TextStyle(
                          color: AppColorsDark.onSurfaceVariant,
                        ),
                        hintStyle: TextStyle(
                          color: AppColorsDark.onSurfaceVariant,
                        ),
                        errorText: _formNotifier.passwordError,
                      ),
                      style: TextStyle(color: AppColorsDark.onSurface),
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
                      style: TextStyle(
                        color: AppColorsDark.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) {
                    final isLoading = state.status == LoginStatus.loading;
                    return FilledButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColorsDark.primary,
                        foregroundColor: AppColorsDark.onPrimary,
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
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColorsDark.outlineVariant),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.or,
                        style: TextStyle(color: AppColorsDark.onSurfaceVariant),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppColorsDark.outlineVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Social buttons
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<LoginCubit, LoginState>(
                        builder: (context, state) {
                          final isLoading = state.status == LoginStatus.loading;
                          return OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context
                                        .read<LoginCubit>()
                                        .signInWithGoogle();
                                  },
                            icon: Icon(
                              Icons.g_mobiledata,
                              color: AppColorsDark.onSurface,
                            ),
                            label: const Text('Google'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColorsDark.onSurface,
                              side: BorderSide(color: AppColorsDark.outline),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
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
                          return OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context
                                        .read<LoginCubit>()
                                        .signInWithApple();
                                  },
                            icon: Icon(Icons.apple,
                                color: AppColorsDark.onSurface),
                            label: const Text('Apple'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColorsDark.onSurface,
                              side: BorderSide(color: AppColorsDark.outline),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Register link
                TextButton(
                  onPressed: () {
                    context.router.push(const RegisterRoute());
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: AppColorsDark.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(text: '${l10n.noAccount} '),
                        TextSpan(
                          text: l10n.register,
                          style: TextStyle(
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
    );
  }
}
