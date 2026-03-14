import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/auth/login/presentation/cubit/login_cubit.dart';
import 'package:music_app/features/auth/login/presentation/notifiers/login_form_notifier.dart';
import 'package:music_app/l10n/app_localizations.dart';

class LoginFormWidget extends StatefulWidget {
  final LoginFormNotifier formNotifier;
  final VoidCallback onLogin;

  const LoginFormWidget({
    required this.formNotifier, required this.onLogin, super.key,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email field
        ListenableBuilder(
          listenable: widget.formNotifier,
          builder: (context, _) {
            return TextFormField(
              controller: widget.formNotifier.emailController,
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
                errorText: widget.formNotifier.emailError,
              ),
              style: const TextStyle(color: AppColorsDark.onSurface),
            );
          },
        ),
        const SizedBox(height: 16),

        // Password field
        ListenableBuilder(
          listenable: widget.formNotifier,
          builder: (context, _) {
            return TextFormField(
              controller: widget.formNotifier.passwordController,
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
                errorText: widget.formNotifier.passwordError,
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
                gradient: isLoading
                    ? null
                    : const LinearGradient(
                        colors: [AppColorsDark.primary, Color(0xFF7C4DFF)],
                      ),
              ),
              child: FilledButton(
                onPressed: isLoading ? null : widget.onLogin,
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
      ],
    );
  }
}
