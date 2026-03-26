import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Atom: "Up Next" label text
class QueueUpNextLabel extends StatelessWidget {
  final String text;

  const QueueUpNextLabel({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColorsDark.onSurface.withValues(alpha: 0.6),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
