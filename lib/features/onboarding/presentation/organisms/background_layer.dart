import 'package:flutter/material.dart';
import 'image_grid.dart';

class BackgroundLayer extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const BackgroundLayer({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -50,
      left: -20,
      right: -20,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Transform.rotate(
          angle: -0.05,
          child: const OnboardingImageGrid(),
        ),
      ),
    );
  }
}
