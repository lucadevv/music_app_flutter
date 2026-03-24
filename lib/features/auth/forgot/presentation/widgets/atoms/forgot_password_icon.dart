import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class ForgotPasswordIcon extends StatelessWidget {
  const ForgotPasswordIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: AppColorsDark.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lock_reset,
        size: 50,
        color: AppColorsDark.primary,
      ),
    );
  }
}
