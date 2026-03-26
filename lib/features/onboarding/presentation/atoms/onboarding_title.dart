import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class OnboardingTitle extends StatelessWidget {
  final String firstPart;
  final String highlightedPart;

  const OnboardingTitle({
    required this.firstPart,
    required this.highlightedPart,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          height: 1.1,
          color: AppColorsDark.onSurface,
        ),
        children: [
          TextSpan(text: '$firstPart\n'),
          TextSpan(
            text: highlightedPart,
            style: const TextStyle(color: AppColorsDark.primary),
          ),
        ],
      ),
    );
  }
}
