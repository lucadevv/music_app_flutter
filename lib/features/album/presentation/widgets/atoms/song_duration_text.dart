import 'package:flutter/material.dart';

/// Átomo: Texto de duración de canción
class SongDurationText extends StatelessWidget {
  final String duration;

  const SongDurationText({required this.duration, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      duration,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 14,
      ),
    );
  }
}
