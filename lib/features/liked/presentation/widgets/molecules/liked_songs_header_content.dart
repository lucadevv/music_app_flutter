import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/liked/presentation/widgets/atoms/liked_icon.dart';

class LikedSongsHeaderContent extends StatelessWidget {
  final String title;
  final String? subtitle;

  const LikedSongsHeaderContent({
    required this.title,
    this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LikedIcon(),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColorsDark.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                color: AppColorsDark.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}
