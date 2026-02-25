import 'package:flutter/material.dart';

class AppColorsDark {
  // const AppColorsDark._();

  // Primary - Vibrante púrpura/rosa para app de música
  static const Color primary = Color(0xFFBB86FC);
  static const Color onPrimary = Color(0xFF000000);
  static const Color primaryContainer = Color(0xFF6200EE);
  static const Color onPrimaryContainer = Color(0xFFE1BEE7);
  static const Color primaryFixed = Color(0xFFE1BEE7);
  static const Color primaryFixedDim = Color(0xFFBB86FC);
  static const Color onPrimaryFixed = Color(0xFF000000);
  static const Color onPrimaryFixedVariant = Color(0xFF6200EE);

  // Secondary - Azul vibrante complementario
  static const Color secondary = Color(0xFF03DAC6);
  static const Color onSecondary = Color(0xFF000000);
  static const Color secondaryContainer = Color(0xFF018786);
  static const Color onSecondaryContainer = Color(0xFFB2DFDB);
  static const Color secondaryFixed = Color(0xFFB2DFDB);
  static const Color secondaryFixedDim = Color(0xFF03DAC6);
  static const Color onSecondaryFixed = Color(0xFF000000);
  static const Color onSecondaryFixedVariant = Color(0xFF018786);

  // Tertiary - Rosa/rojo para acentos
  static const Color tertiary = Color(0xFFFF6B9D);
  static const Color onTertiary = Color(0xFF000000);
  static const Color tertiaryContainer = Color(0xFFC2185B);
  static const Color onTertiaryContainer = Color(0xFFFFE0E6);
  static const Color tertiaryFixed = Color(0xFFFFE0E6);
  static const Color tertiaryFixedDim = Color(0xFFFF6B9D);
  static const Color onTertiaryFixed = Color(0xFF000000);
  static const Color onTertiaryFixedVariant = Color(0xFFC2185B);

  // Error
  static const Color error = Color(0xFFCF6679);
  static const Color onError = Color(0xFF000000);
  static const Color errorContainer = Color(0xFFB00020);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Surface - Negros profundos para fondo de música
  static const Color surface = Color(0xFF121212);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFF000000);
  static const Color surfaceBright = Color(0xFF2C2C2C);
  static const Color surfaceContainerLowest = Color(0xFF000000);
  static const Color surfaceContainerLow = Color(0xFF1A1A1A);
  static const Color surfaceContainer = Color(0xFF1E1E1E);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353535);

  static const Color onSurfaceVariant = Color(0xFFB3B3B3);
  static const Color outline = Color(0xFF5C5C5C);
  static const Color outlineVariant = Color(0xFF3A3A3A);

  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);

  static const Color inverseSurface = Color(0xFFE1E1E1);
  static const Color onInverseSurface = Color(0xFF121212);
  static const Color inversePrimary = Color(0xFF6200EE);
  static const Color surfaceTint = Color(0xFFBB86FC);
}

ColorScheme createDarkColorScheme() {
  return const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColorsDark.primary,
    onPrimary: AppColorsDark.onPrimary,
    primaryContainer: AppColorsDark.primaryContainer,
    onPrimaryContainer: AppColorsDark.onPrimaryContainer,
    primaryFixed: AppColorsDark.primaryFixed,
    primaryFixedDim: AppColorsDark.primaryFixedDim,
    onPrimaryFixed: AppColorsDark.onPrimaryFixed,
    onPrimaryFixedVariant: AppColorsDark.onPrimaryFixedVariant,
    secondary: AppColorsDark.secondary,
    onSecondary: AppColorsDark.onSecondary,
    secondaryContainer: AppColorsDark.secondaryContainer,
    onSecondaryContainer: AppColorsDark.onSecondaryContainer,
    secondaryFixed: AppColorsDark.secondaryFixed,
    secondaryFixedDim: AppColorsDark.secondaryFixedDim,
    onSecondaryFixed: AppColorsDark.onSecondaryFixed,
    onSecondaryFixedVariant: AppColorsDark.onSecondaryFixedVariant,
    tertiary: AppColorsDark.tertiary,
    onTertiary: AppColorsDark.onTertiary,
    tertiaryContainer: AppColorsDark.tertiaryContainer,
    onTertiaryContainer: AppColorsDark.onTertiaryContainer,
    tertiaryFixed: AppColorsDark.tertiaryFixed,
    tertiaryFixedDim: AppColorsDark.tertiaryFixedDim,
    onTertiaryFixed: AppColorsDark.onTertiaryFixed,
    onTertiaryFixedVariant: AppColorsDark.onTertiaryFixedVariant,
    error: AppColorsDark.error,
    onError: AppColorsDark.onError,
    errorContainer: AppColorsDark.errorContainer,
    onErrorContainer: AppColorsDark.onErrorContainer,
    surface: AppColorsDark.surface,
    onSurface: AppColorsDark.onSurface,
    surfaceDim: AppColorsDark.surfaceDim,
    surfaceBright: AppColorsDark.surfaceBright,
    surfaceContainerLowest: AppColorsDark.surfaceContainerLowest,
    surfaceContainerLow: AppColorsDark.surfaceContainerLow,
    surfaceContainer: AppColorsDark.surfaceContainer,
    surfaceContainerHigh: AppColorsDark.surfaceContainerHigh,
    surfaceContainerHighest: AppColorsDark.surfaceContainerHighest,
    onSurfaceVariant: AppColorsDark.onSurfaceVariant,
    outline: AppColorsDark.outline,
    outlineVariant: AppColorsDark.outlineVariant,
    shadow: AppColorsDark.shadow,
    scrim: AppColorsDark.scrim,
    inverseSurface: AppColorsDark.inverseSurface,
    onInverseSurface: AppColorsDark.onInverseSurface,
    inversePrimary: AppColorsDark.inversePrimary,
    surfaceTint: AppColorsDark.surfaceTint,
  );
}
