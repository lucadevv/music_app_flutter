import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class ForgotPasswordDescription extends StatelessWidget {
  final String description;

  const ForgotPasswordDescription({required this.description, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: const TextStyle(
        fontSize: 16,
        color: AppColorsDark.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }
}
