import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class LikedIcon extends StatelessWidget {
  final double size;
  final bool filled;

  const LikedIcon({super.key, this.size = 80, this.filled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColorsDark.primary, AppColorsDark.secondary],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        filled ? Icons.favorite : Icons.favorite_border,
        size: size,
        color: Colors.white,
      ),
    );
  }
}
