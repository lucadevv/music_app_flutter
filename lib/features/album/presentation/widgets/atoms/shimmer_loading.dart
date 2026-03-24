import 'package:flutter/material.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';

/// Átomo: Loading shimmer para el header del álbum
class AlbumHeaderShimmer extends StatelessWidget {
  const AlbumHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThumbnailShimmer(width: 180, height: 180),
          SizedBox(height: 16),
          TextShimmer(width: 200, height: 24),
          SizedBox(height: 8),
          TextShimmer(width: 120, height: 14),
        ],
      ),
    );
  }
}

/// Átomo: Loading shimmer para los botones de acción
class ActionButtonsShimmer extends StatelessWidget {
  const ActionButtonsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(child: ButtonShimmer(height: 48)),
          SizedBox(width: 16),
          ShimmerContainer(width: 48, height: 48, borderRadius: 24),
          SizedBox(width: 8),
          ShimmerContainer(width: 48, height: 48, borderRadius: 24),
          SizedBox(width: 8),
          ShimmerContainer(width: 48, height: 48, borderRadius: 24),
        ],
      ),
    );
  }
}
