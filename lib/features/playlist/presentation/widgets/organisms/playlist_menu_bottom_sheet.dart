import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class PlaylistMenuBottomSheet extends StatelessWidget {
  final String playlistTitle;
  final VoidCallback onShare;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onShufflePlay;

  const PlaylistMenuBottomSheet({
    required this.playlistTitle, required this.onShare, required this.onAddToPlaylist, required this.onShufflePlay, super.key,
  });

  static void show({
    required BuildContext context,
    required String playlistTitle,
    required VoidCallback onShare,
    required VoidCallback onAddToPlaylist,
    required VoidCallback onShufflePlay,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlaylistMenuBottomSheet(
        playlistTitle: playlistTitle,
        onShare: onShare,
        onAddToPlaylist: onAddToPlaylist,
        onShufflePlay: onShufflePlay,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _MenuItem(
            icon: Icons.share,
            label: 'Share',
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(
                ClipboardData(text: 'Check out this playlist: $playlistTitle'),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Playlist link copied to clipboard'),
                  backgroundColor: AppColorsDark.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          _MenuItem(
            icon: Icons.playlist_add,
            label: 'Add to playlist',
            onTap: () {
              Navigator.pop(context);
              onAddToPlaylist();
            },
          ),
          _MenuItem(
            icon: Icons.shuffle,
            label: 'Shuffle play',
            onTap: () {
              Navigator.pop(context);
              onShufflePlay();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
