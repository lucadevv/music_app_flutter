import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Atom: Badge showing "Now Playing" label
class QueueNowPlayingBadge extends StatelessWidget {
  final String text;

  const QueueNowPlayingBadge({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColorsDark.onSurface.withValues(alpha: 0.6),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
