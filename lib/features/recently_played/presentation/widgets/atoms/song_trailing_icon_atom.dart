import 'package:flutter/material.dart';

class SongTrailingIconAtom extends StatelessWidget {
  const SongTrailingIconAtom({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.play_circle_outline,
      color: Colors.white.withValues(alpha: 0.6),
    );
  }
}
