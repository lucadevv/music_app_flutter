import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado del locale de la app
class LocaleState {
  final Locale locale;
  final bool isLoading;

  const LocaleState({
    required this.locale,
    this.isLoading = false,
  });

  LocaleState copyWith({
    Locale? locale,
    bool? isLoading,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory LocaleState.initial() {
    return const LocaleState(
      locale: Locale('en'),
      isLoading: true,
    );
  }
}

/// Cubit para manejar el locale de la app con persistencia
class LocaleCubit extends Cubit<LocaleState> {
  static const String _localeKey = 'app_locale';
  final SharedPreferences _prefs;

  LocaleCubit(this._prefs) : super(LocaleState.initial()) {
    _loadSavedLocale();
  }

  /// Carga el locale guardado en SharedPreferences
  Future<void> _loadSavedLocale() async {
    try {
      final savedLocale = _prefs.getString(_localeKey);
      if (savedLocale != null) {
        emit(state.copyWith(
          locale: Locale(savedLocale),
          isLoading: false,
        ));
      } else {
        // Si no hay locale guardado, usar inglés por defecto
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Cambia el locale de la app y lo persiste
  Future<void> setLocale(Locale locale) async {
    try {
      await _prefs.setString(_localeKey, locale.languageCode);
      emit(state.copyWith(locale: locale));
    } catch (e) {
      // Si falla la persistencia, al menos actualizamos el estado
      emit(state.copyWith(locale: locale));
    }
  }

  /// Cambia el locale usando el código de idioma
  Future<void> setLocaleByCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// Obtiene el locale actual
  Locale get currentLocale => state.locale;

  /// Lista de locales soportados
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  /// Nombres de los idiomas para mostrar en la UI
  static const Map<String, String> localeNames = {
    'en': 'English',
    'es': 'Español',
  };
}
