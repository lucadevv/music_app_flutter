import 'package:flutter/material.dart';

/// Atom: "Up Next" label text
class QueueUpNextLabel extends StatelessWidget {
  final String text;

  const QueueUpNextLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
