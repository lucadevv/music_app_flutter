import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Atom: Empty queue icon
class QueueEmptyIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const QueueEmptyIcon({super.key, this.size = 64, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.queue_music,
      size: size,
      color: color ?? AppColorsDark.onSurface.withValues(alpha: 0.3),
    );
  }
}
