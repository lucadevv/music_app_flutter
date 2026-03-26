import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class BackArrowButton extends StatelessWidget {
  final VoidCallback? onTap;

  const BackArrowButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_new,
        color: AppColorsDark.onSurface,
      ),
      onPressed: onTap,
    );
  }
}
