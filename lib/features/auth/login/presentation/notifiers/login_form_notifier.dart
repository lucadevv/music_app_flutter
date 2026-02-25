import 'package:flutter/material.dart';

/// Notifier para manejar las validaciones del formulario de login
class LoginFormNotifier extends ChangeNotifier {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  String? _emailError;
  String? _passwordError;

  LoginFormNotifier()
      : emailController = TextEditingController(),
        passwordController = TextEditingController() {
    // Validar en tiempo real cuando cambian los valores
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  bool get hasErrors => _emailError != null || _passwordError != null;

  void _onEmailChanged() {
    validateEmail(emailController.text);
  }

  void _onPasswordChanged() {
    validatePassword(passwordController.text);
  }

  /// Valida el email
  bool validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      _emailError = 'Por favor ingresa tu email';
      notifyListeners();
      return false;
    }
    if (!value.contains('@') || !value.contains('.')) {
      _emailError = 'Ingresa un email válido';
      notifyListeners();
      return false;
    }
    _emailError = null;
    notifyListeners();
    return true;
  }

  /// Valida la contraseña
  bool validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      _passwordError = 'Por favor ingresa tu contraseña';
      notifyListeners();
      return false;
    }
    _passwordError = null;
    notifyListeners();
    return true;
  }

  /// Valida todo el formulario
  bool validateForm({
    required String? email,
    required String? password,
  }) {
    final emailValid = validateEmail(email);
    final passwordValid = validatePassword(password);

    return emailValid && passwordValid;
  }

  /// Limpia todos los errores
  void clearErrors() {
    _emailError = null;
    _passwordError = null;
    notifyListeners();
  }

  /// Resetea el notifier
  void reset() {
    emailController.clear();
    passwordController.clear();
    clearErrors();
  }

  @override
  void dispose() {
    emailController.removeListener(_onEmailChanged);
    passwordController.removeListener(_onPasswordChanged);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
