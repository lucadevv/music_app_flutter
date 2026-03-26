import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class UserPlaylistsEmptyMolecule extends StatelessWidget {
  const UserPlaylistsEmptyMolecule({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_play, size: 64, color: AppColorsDark.onSurface24),
          SizedBox(height: 16),
          Text(
            'No playlists',
            style: TextStyle(color: AppColorsDark.onSurface54),
          ),
        ],
      ),
    );
  }
}
