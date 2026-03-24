import 'package:flutter/material.dart';

class UserPlaylistsEmptyMolecule extends StatelessWidget {
  const UserPlaylistsEmptyMolecule({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_play, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text('No playlists', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
