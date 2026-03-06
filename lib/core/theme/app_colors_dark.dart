import 'package:flutter/material.dart';

class AppColorsDark {
  // const AppColorsDark._();

  // Primary - Cyan vibrante para app de música moderna
  static const Color primary = Color(0xFF00E5FF);
  static const Color onPrimary = Color(0xFF000000);
  static const Color primaryContainer = Color(0xFF00ACC1);
  static const Color onPrimaryContainer = Color(0xFFE0FFFF);
  static const Color primaryFixed = Color(0xFFE0FFFF);
  static const Color primaryFixedDim = Color(0xFF00E5FF);
  static const Color onPrimaryFixed = Color(0xFF000000);
  static const Color onPrimaryFixedVariant = Color(0xFF00ACC1);

  // Secondary - Gris/blanco para elementos neutros secundarios
  static const Color secondary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color secondaryContainer = Color(0xFFE0E0E0);
  static const Color onSecondaryContainer = Color(0xFF333333);
  static const Color secondaryFixed = Color(0xFFE0E0E0);
  static const Color secondaryFixedDim = Color(0xFFFFFFFF);
  static const Color onSecondaryFixed = Color(0xFF000000);
  static const Color onSecondaryFixedVariant = Color(0xFF333333);

  // Tertiary - Acentos alternativos si se requieren
  static const Color tertiary = Color(0xFF7C4DFF);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF6200EA);
  static const Color onTertiaryContainer = Color(0xFFE8EAF6);
  static const Color tertiaryFixed = Color(0xFFE8EAF6);
  static const Color tertiaryFixedDim = Color(0xFF7C4DFF);
  static const Color onTertiaryFixed = Color(0xFFFFFFFF);
  static const Color onTertiaryFixedVariant = Color(0xFF6200EA);

  // Error
  static const Color error = Color(0xFFCF6679);
  static const Color onError = Color(0xFF000000);
  static const Color errorContainer = Color(0xFFB00020);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Surface - Negros profundos para fondo de música (estilo Spotify/Apple Music oscuro)
  static const Color surface = Color(0xFF0D0D12);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFF000000);
  static const Color surfaceBright = Color(0xFF1E1E26);
  static const Color surfaceContainerLowest = Color(0xFF06060A);
  static const Color surfaceContainerLow = Color(0xFF15151C);
  static const Color surfaceContainer = Color(0xFF1C1C24);
  static const Color surfaceContainerHigh = Color(0xFF262632);
  static const Color surfaceContainerHighest = Color(0xFF333342);

  static const Color onSurfaceVariant = Color(0xFF9E9E9E);
  static const Color outline = Color(0xFF424242);
  static const Color outlineVariant = Color(0xFF212121);

  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);

  static const Color inverseSurface = Color(0xFFE0E0E0);
  static const Color onInverseSurface = Color(0xFF0D0D12);
  static const Color inversePrimary = Color(0xFF0083B0);
  static const Color surfaceTint = Color(0xFF00E5FF);
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
