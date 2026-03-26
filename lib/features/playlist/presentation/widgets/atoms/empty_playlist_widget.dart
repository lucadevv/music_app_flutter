import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class EmptyPlaylistWidget extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyPlaylistWidget({
    super.key,
    this.icon = Icons.music_off,
    this.message = 'No songs in this playlist',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColorsDark.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppColorsDark.onSurface.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
