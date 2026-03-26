import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class RelaxTextStyles {
  RelaxTextStyles._();

  static TextStyle get greeting => TextStyle(
    color: AppColorsDark.onSurface.withValues(alpha: 0.75),
    fontSize: 16,
  );

  static TextStyle get title => const TextStyle(
    color: AppColorsDark.onSurface,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get sectionTitle => const TextStyle(
    color: AppColorsDark.onSurface,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get cardTitle => const TextStyle(
    color: AppColorsDark.onSurface,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get cardSubtitle => TextStyle(
    color: AppColorsDark.onSurface.withValues(alpha: 0.6),
    fontSize: 12,
  );

  static TextStyle chip({required bool isSelected}) => TextStyle(
    color: isSelected ? AppColorsDark.surfaceDim : AppColorsDark.onSurface,
    fontSize: 14,
    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
  );
}
