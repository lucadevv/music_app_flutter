import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Atom: Trailing widget for queue items (duration + remove button)
class QueueItemTrailing extends StatelessWidget {
  final String duration;
  final VoidCallback onRemove;

  const QueueItemTrailing({
    required this.duration,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          duration,
          style: TextStyle(
            color: AppColorsDark.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.close,
            color: AppColorsDark.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          onPressed: onRemove,
        ),
      ],
    );
  }
}
