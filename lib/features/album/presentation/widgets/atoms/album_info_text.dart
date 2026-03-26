import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Átomo: Textos de información del álbum (título y subtítulo)
class AlbumInfoText extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double titleFontSize;
  final double subtitleFontSize;

  const AlbumInfoText({
    required this.title,
    super.key,
    this.titleFontSize = 24,
    this.subtitle,
    this.subtitleFontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColorsDark.onSurface,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: TextStyle(
              color: AppColorsDark.onSurface.withValues(alpha: 0.6),
              fontSize: subtitleFontSize,
            ),
          ),
        ],
      ],
    );
  }
}
