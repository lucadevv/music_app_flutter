import 'package:flutter/material.dart';

/// Átomo: Textos de información del álbum (título y subtítulo)
class AlbumInfoText extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double titleFontSize;
  final double subtitleFontSize;

  const AlbumInfoText({
    super.key,
    required this.title,
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
            color: Colors.white,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: subtitleFontSize,
            ),
          ),
        ],
      ],
    );
  }
}
