import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class BackButtonAtom extends StatelessWidget {
  final VoidCallback onPressed;

  const BackButtonAtom({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_new,
        color: AppColorsDark.onSurface,
      ),
      onPressed: onPressed,
    );
  }
}
