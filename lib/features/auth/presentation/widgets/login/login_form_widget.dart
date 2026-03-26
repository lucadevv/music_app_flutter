import 'package:flutter/material.dart';
import 'package:music_app/features/auth/presentation/notifiers/login_form_notifier.dart';
import 'package:music_app/features/auth/presentation/widgets/login/atoms/email_input.dart';
import 'package:music_app/features/auth/presentation/widgets/login/atoms/forgot_password_link.dart';
import 'package:music_app/features/auth/presentation/widgets/login/atoms/login_button.dart';
import 'package:music_app/features/auth/presentation/widgets/login/atoms/password_input.dart';

/// Molecule: Login form combining email, password fields, forgot password, and submit button
class LoginFormWidget extends StatelessWidget {
  final LoginFormNotifier formNotifier;
  final VoidCallback onLogin;

  const LoginFormWidget({
    required this.formNotifier,
    required this.onLogin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmailInput(formNotifier: formNotifier),
        const SizedBox(height: 16),

        PasswordInput(formNotifier: formNotifier),
        const SizedBox(height: 8),

        const ForgotPasswordLink(),
        const SizedBox(height: 24),

        LoginButton(onPressed: onLogin),
      ],
    );
  }
}
