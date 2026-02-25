import 'package:flutter/material.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'player_shimmer_widgets.dart';

/// Widget para mostrar metadata de la canción (views, explicit)
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar metadata de la canción
class PlayerMetadataWidget extends StatelessWidget {
  final NowPlayingData track;
  final bool isLoading;

  const PlayerMetadataWidget({
    super.key,
    required this.track,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MetadataShimmer();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility,
            size: 16,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            track.views,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          if (track.isExplicit) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'E',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
