import 'package:flutter/material.dart';
import 'package:music_app/features/auth/register/presentation/notifiers/register_form_notifier.dart';
import 'register_text_field.dart';

class RegisterFormFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final RegisterFormNotifier formNotifier;
  final ValueNotifier<bool> obscurePassword;
  final ValueNotifier<bool> obscureConfirmPassword;

  const RegisterFormFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formNotifier,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Email field - según RegisterRequest: email, password, firstName, lastName
        ListenableBuilder(
          listenable: formNotifier,
          builder: (context, _) {
            return RegisterTextField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'tu@email.com',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              errorText: formNotifier.emailError,
              onChanged: (value) => formNotifier.validateEmail(value),
            );
          },
        ),
        const SizedBox(height: 16),

        // First name field
        ListenableBuilder(
          listenable: formNotifier,
          builder: (context, _) {
            return RegisterTextField(
              controller: firstNameController,
              labelText: 'Nombre',
              hintText: 'Juan',
              prefixIcon: Icons.person,
              errorText: formNotifier.firstNameError,
              onChanged: (value) => formNotifier.validateFirstName(value),
            );
          },
        ),
        const SizedBox(height: 16),

        // Last name field
        ListenableBuilder(
          listenable: formNotifier,
          builder: (context, _) {
            return RegisterTextField(
              controller: lastNameController,
              labelText: 'Apellido',
              hintText: 'Pérez',
              prefixIcon: Icons.person_outline,
              errorText: formNotifier.lastNameError,
              onChanged: (value) => formNotifier.validateLastName(value),
            );
          },
        ),
        const SizedBox(height: 16),
        // Password field
        ListenableBuilder(
          listenable: formNotifier,
          builder: (context, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: obscurePassword,
              builder: (context, isObscure, _) {
                return RegisterTextField(
                  controller: passwordController,
                  labelText: 'Contraseña',
                  hintText: 'Mínimo 8 caracteres',
                  prefixIcon: Icons.lock,
                  obscureText: isObscure,
                  suffixIcon: isObscure
                      ? Icons.visibility
                      : Icons.visibility_off,
                  errorText: formNotifier.passwordError,
                  onSuffixIconPressed: () {
                    obscurePassword.value = !obscurePassword.value;
                  },
                  onChanged: (value) => formNotifier.validatePassword(value),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        // Confirm password field (solo para validación, no va en RegisterRequest)
        ListenableBuilder(
          listenable: formNotifier,
          builder: (context, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: obscureConfirmPassword,
              builder: (context, isObscure, _) {
                return RegisterTextField(
                  controller: confirmPasswordController,
                  labelText: 'Confirmar contraseña',
                  hintText: 'Repite tu contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: isObscure,
                  suffixIcon: isObscure
                      ? Icons.visibility
                      : Icons.visibility_off,
                  errorText: formNotifier.confirmPasswordError,
                  onSuffixIconPressed: () {
                    obscureConfirmPassword.value =
                        !obscureConfirmPassword.value;
                  },
                  onChanged: (value) => formNotifier.validateConfirmPassword(
                    value,
                    passwordController.text,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
