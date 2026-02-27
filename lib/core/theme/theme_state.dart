part of 'theme_cubit.dart';

/// Estado del tema de la aplicación
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Representar el estado del tema
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  /// Estado inicial con tema oscuro por defecto
  const ThemeState.initial() : themeMode = ThemeMode.dark;

  /// Crea una copia del estado con los cambios proporcionados
  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  /// Getters de conveniencia
  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;
  bool get isSystemMode => themeMode == ThemeMode.system;

  @override
  List<Object?> get props => [themeMode];
}
