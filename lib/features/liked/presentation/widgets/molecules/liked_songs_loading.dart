import 'package:flutter/material.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';

class LikedSongsLoading extends StatelessWidget {
  const LikedSongsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Row(
            children: [
              ShimmerContainer(width: 56, height: 56, borderRadius: 28),
              SizedBox(width: 16),
              ShimmerContainer(width: 48, height: 48, borderRadius: 24),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => const SongListItemShimmer(),
          ),
        ),
      ],
    );
  }
}
