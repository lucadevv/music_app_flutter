import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class PlayIcon extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;

  const PlayIcon({super.key, this.onTap, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColorsDark.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
      ),
    );
  }
}
