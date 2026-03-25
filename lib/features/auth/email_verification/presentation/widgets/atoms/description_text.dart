import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Átomo: Texto de descripción
class DescriptionText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const DescriptionText({
    required this.text, super.key,
    this.fontSize = 16,
    this.color = AppColorsDark.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: fontSize, color: color),
    );
  }
}
