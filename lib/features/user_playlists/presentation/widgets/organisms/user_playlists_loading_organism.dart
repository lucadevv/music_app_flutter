import 'package:flutter/material.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';

class UserPlaylistsLoadingOrganism extends StatelessWidget {
  const UserPlaylistsLoadingOrganism({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ShimmerContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 8,
              ),
            ),
            SizedBox(height: 8),
            TextShimmer(width: 120, height: 14),
            SizedBox(height: 4),
            TextShimmer(width: 80, height: 12),
          ],
        );
      },
    );
  }
}
