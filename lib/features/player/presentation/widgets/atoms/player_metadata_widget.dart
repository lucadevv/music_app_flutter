import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

import '../organisms/player_shimmer_widgets.dart';

/// Widget para mostrar metadata de la canción (views, explicit)
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar metadata de la canción
class PlayerMetadataWidget extends StatelessWidget {
  final NowPlayingData track;
  final bool isLoading;

  const PlayerMetadataWidget({
    required this.track,
    super.key,
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
        color: AppColorsDark.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility,
            size: 16,
            color: AppColorsDark.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            track.views,
            style: TextStyle(
              color: AppColorsDark.onSurface.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          if (track.isExplicit) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColorsDark.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'E',
                style: TextStyle(
                  color: AppColorsDark.onSurface,
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
