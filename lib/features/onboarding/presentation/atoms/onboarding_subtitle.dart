import 'package:flutter/material.dart';

class OnboardingSubtitle extends StatelessWidget {
  final String text;

  const OnboardingSubtitle({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: Colors.white.withValues(alpha: 0.7),
        fontFamily: 'Poppins',
        height: 1.4,
      ),
    );
  }
}
