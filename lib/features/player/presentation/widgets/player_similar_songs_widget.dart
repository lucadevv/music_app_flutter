import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Widget para mostrar canciones similares
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar lista de canciones similares
class PlayerSimilarSongsWidget extends StatelessWidget {
  const PlayerSimilarSongsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Songs similar to this',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _SimilarSongItem(
          title: 'Sick Boy',
          artist: 'The Chainsmokers',
        ),
        _SimilarSongItem(
          title: 'Until You W...',
          artist: 'The Chainsmokers',
        ),
        _SimilarSongItem(
          title: 'Pay No Mind',
          artist: 'The Chainsmokers',
        ),
        _SimilarSongItem(
          title: 'Remind me ...',
          artist: 'The Chainsmokers',
        ),
      ],
    );
  }
}

class _SimilarSongItem extends StatelessWidget {
  final String title;
  final String artist;

  const _SimilarSongItem({
    required this.title,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColorsDark.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.music_note,
          color: AppColorsDark.primary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.more_vert,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        onPressed: () {},
      ),
    );
  }
}
