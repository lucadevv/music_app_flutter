import 'package:flutter/material.dart';

/// Notifier para manejar las validaciones del formulario de registro
class RegisterFormNotifier extends ChangeNotifier {
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  String? get firstNameError => _firstNameError;
  String? get lastNameError => _lastNameError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;

  bool get hasErrors =>
      _firstNameError != null ||
      _lastNameError != null ||
      _emailError != null ||
      _passwordError != null ||
      _confirmPasswordError != null;

  /// Valida el nombre
  bool validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      _firstNameError = 'Por favor ingresa tu nombre';
      notifyListeners();
      return false;
    }
    _firstNameError = null;
    notifyListeners();
    return true;
  }

  /// Valida el apellido
  bool validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      _lastNameError = 'Por favor ingresa tu apellido';
      notifyListeners();
      return false;
    }
    _lastNameError = null;
    notifyListeners();
    return true;
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
    if (value.length < 8) {
      _passwordError = 'La contraseña debe tener al menos 8 caracteres';
      notifyListeners();
      return false;
    }
    _passwordError = null;
    notifyListeners();
    return true;
  }

  /// Valida la confirmación de contraseña
  bool validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      _confirmPasswordError = 'Por favor confirma tu contraseña';
      notifyListeners();
      return false;
    }
    if (value != password) {
      _confirmPasswordError = 'Las contraseñas no coinciden';
      notifyListeners();
      return false;
    }
    _confirmPasswordError = null;
    notifyListeners();
    return true;
  }

  /// Valida todo el formulario
  bool validateForm({
    required String? firstName,
    required String? lastName,
    required String? email,
    required String? password,
    required String? confirmPassword,
  }) {
    final firstNameValid = validateFirstName(firstName);
    final lastNameValid = validateLastName(lastName);
    final emailValid = validateEmail(email);
    final passwordValid = validatePassword(password);
    final confirmPasswordValid = validateConfirmPassword(confirmPassword, password ?? '');

    return firstNameValid &&
        lastNameValid &&
        emailValid &&
        passwordValid &&
        confirmPasswordValid;
  }

  /// Limpia todos los errores
  void clearErrors() {
    _firstNameError = null;
    _lastNameError = null;
    _emailError = null;
    _passwordError = null;
    _confirmPasswordError = null;
    notifyListeners();
  }

  /// Resetea el notifier
  void reset() {
    clearErrors();
  }
}
