import 'package:flutter/material.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'player_shimmer_widgets.dart';

/// Widget para mostrar la información de la canción (título, artista, álbum)
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar información de la canción
class PlayerInfoWidget extends StatelessWidget {
  final NowPlayingData track;
  final bool isLoading;

  const PlayerInfoWidget({
    super.key,
    required this.track,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título
        if (isLoading)
          const TitleShimmer()
        else
          Text(
            track.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 8),

        // Artista
        if (isLoading)
          const SubtitleShimmer()
        else
          Text(
            track.artistsNames,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 4),

        // Álbum
        if (isLoading)
          const SubtitleShimmer(width: 150)
        else
          Text(
            track.album.name,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
