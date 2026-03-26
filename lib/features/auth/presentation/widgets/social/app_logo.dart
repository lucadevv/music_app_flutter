// Molecule: AppLogo
// Represents the application logo with container and shadow

import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColorsDark.primaryContainer,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColorsDark.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const ClipOval(
        child: Image(
          image: AssetImage('assets/img/logo_app.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
