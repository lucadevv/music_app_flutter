import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class PlaylistNotFoundMolecule extends StatelessWidget {
  const PlaylistNotFoundMolecule({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Playlist not found',
        style: TextStyle(color: AppColorsDark.onSurface),
      ),
    );
  }
}
