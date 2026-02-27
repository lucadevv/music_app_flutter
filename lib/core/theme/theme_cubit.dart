import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

/// Cubit para gestionar el tema de la aplicación
///
/// SOLID:
/// - Single Responsibility: Gestiona solo el estado del tema
/// - Open/Closed: Extensible para nuevos modos de tema
///
/// Patrón aplicado: State Management con BLoC/Cubit
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(const ThemeState.initial()) {
    _loadTheme();
  }

  /// Carga el tema guardado desde SharedPreferences
  void _loadTheme() {
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      final themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => ThemeMode.dark,
      );
      emit(state.copyWith(themeMode: themeMode));
    }
  }

  /// Establece el modo de tema
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
    emit(state.copyWith(themeMode: mode));
  }

  /// Alterna entre tema claro y oscuro
  Future<void> toggleTheme() async {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Establece tema oscuro
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Establece tema claro
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Establece tema del sistema
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }
}
