import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class OnboardingTitle extends StatelessWidget {
  final String firstPart;
  final String highlightedPart;

  const OnboardingTitle({
    super.key,
    required this.firstPart,
    required this.highlightedPart,
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
          color: Colors.white,
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
