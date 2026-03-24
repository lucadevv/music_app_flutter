import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class SuccessIcon extends StatelessWidget {
  const SuccessIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.check_circle,
      size: 80,
      color: AppColorsDark.primary,
    );
  }
}
