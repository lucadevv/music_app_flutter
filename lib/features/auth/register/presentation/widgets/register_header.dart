import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Crear cuenta',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColorsDark.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Regístrate para comenzar',
          style: TextStyle(
            fontSize: 16,
            color: AppColorsDark.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
