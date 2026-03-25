import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Átomo: Display del email del usuario
class EmailDisplayText extends StatelessWidget {
  final String email;

  const EmailDisplayText({required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      email,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColorsDark.primary,
      ),
    );
  }
}
