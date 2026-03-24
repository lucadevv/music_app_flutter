import 'package:flutter/material.dart';
import 'package:music_app/core/utils/extension/sizedbox_extension.dart';
import 'package:music_app/features/auth/register/presentation/widgets/login_link.dart';
import 'package:music_app/features/auth/register/presentation/widgets/register_button.dart';
import 'package:music_app/features/auth/register/presentation/widgets/register_form_fields.dart';
import 'package:music_app/features/auth/register/presentation/widgets/register_header.dart';
import 'package:music_app/features/auth/register/presentation/widgets/social_buttons.dart';
import 'package:music_app/features/auth/register/presentation/notifiers/register_form_notifier.dart';

class RegisterBodyContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final ValueNotifier<bool> obscurePassword;
  final ValueNotifier<bool> obscureConfirmPassword;
  final RegisterFormNotifier formNotifier;
  final VoidCallback onRegister;

  const RegisterBodyContent({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.formNotifier,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            32.spaceh,
            const RegisterHeader(),
            RegisterFormFields(
              firstNameController: firstNameController,
              lastNameController: lastNameController,
              emailController: emailController,
              passwordController: passwordController,
              confirmPasswordController: confirmPasswordController,
              formNotifier: formNotifier,
              obscurePassword: obscurePassword,
              obscureConfirmPassword: obscureConfirmPassword,
            ),
            const SizedBox(height: 32),
            RegisterButton(onPressed: onRegister),
            const SizedBox(height: 24),
            const SocialButtons(),
            const SizedBox(height: 24),
            const LoginLink(),
          ],
        ),
      ),
    );
  }
}
