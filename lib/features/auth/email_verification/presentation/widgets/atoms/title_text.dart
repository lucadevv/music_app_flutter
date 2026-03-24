import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Átomo: Título principal de verificación
class TitleText extends StatelessWidget {
  final String text;

  const TitleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColorsDark.onSurface,
      ),
    );
  }
}
