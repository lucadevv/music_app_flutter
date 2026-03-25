import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class ForgotPasswordTitle extends StatelessWidget {
  final String title;

  const ForgotPasswordTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColorsDark.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }
}
