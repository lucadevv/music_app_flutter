import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class SongTrailingIconAtom extends StatelessWidget {
  const SongTrailingIconAtom({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.play_circle_outline,
      color: AppColorsDark.onSurface.withValues(alpha: 0.6),
    );
  }
}
