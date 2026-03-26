import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class OnboardingSubtitle extends StatelessWidget {
  final String text;

  const OnboardingSubtitle({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: AppColorsDark.onSurface.withValues(alpha: 0.7),
        fontFamily: 'Poppins',
        height: 1.4,
      ),
    );
  }
}
