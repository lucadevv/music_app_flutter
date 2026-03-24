import 'package:flutter/material.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';

class ArtistLoadingButtonsAtom extends StatelessWidget {
  const ArtistLoadingButtonsAtom({super.key});

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
        ],
      ),
    );
  }
}

class ArtistLoadingAlbumShimmer extends StatelessWidget {
  const ArtistLoadingAlbumShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThumbnailShimmer(width: 140, height: 130),
          SizedBox(height: 8),
          TextShimmer(height: 14),
          SizedBox(height: 4),
          TextShimmer(width: 80, height: 12),
        ],
      ),
    );
  }
}

class ArtistLoadingTitleShimmer extends StatelessWidget {
  final double width;

  const ArtistLoadingTitleShimmer({super.key, this.width = 100});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: TextShimmer(width: width, height: 20),
    );
  }
}
