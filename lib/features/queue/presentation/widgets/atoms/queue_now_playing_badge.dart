import 'package:flutter/material.dart';

/// Atom: Badge showing "Now Playing" label
class QueueNowPlayingBadge extends StatelessWidget {
  final String text;

  const QueueNowPlayingBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
