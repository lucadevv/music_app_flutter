import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class AuthBlurOverlay extends StatelessWidget {
  const AuthBlurOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        color: AppColorsDark.surface.withValues(alpha: 0.7),
      ),
    );
  }
}
