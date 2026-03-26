import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class PlaylistLoadMoreButton extends StatelessWidget {
  final int currentCount;
  final int? totalCount;
  final VoidCallback onPressed;

  const PlaylistLoadMoreButton({
    required this.currentCount,
    required this.onPressed,
    super.key,
    this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          'Cargar más canciones ($currentCount/${totalCount?.toString() ?? "?"})',
          style: const TextStyle(
            color: AppColorsDark.onSurface54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
