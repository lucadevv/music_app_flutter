import 'package:flutter/material.dart';

/// Atom: Trailing widget for queue items (duration + remove button)
class QueueItemTrailing extends StatelessWidget {
  final String duration;
  final VoidCallback onRemove;

  const QueueItemTrailing({
    required this.duration, required this.onRemove, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          duration,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white.withValues(alpha: 0.6),
            size: 20,
          ),
          onPressed: onRemove,
        ),
      ],
    );
  }
}
