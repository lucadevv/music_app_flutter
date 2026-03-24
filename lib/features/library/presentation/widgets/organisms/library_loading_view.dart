import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';

/// Vista de carga de la biblioteca con efecto shimmer.
class LibraryLoadingView extends StatelessWidget {
  const LibraryLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TextShimmer(width: 140, height: 24),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(4, (index) {
                return Container(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColorsDark.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextShimmer(width: 100, height: 24),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 4,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      ThumbnailShimmer(width: 156, height: 156),
                      SizedBox(height: 8),
                      TextShimmer(width: 120, height: 16),
                      SizedBox(height: 4),
                      TextShimmer(width: 60, height: 12),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextShimmer(width: 120, height: 24),
          ),
          const SizedBox(height: 16),
          const SongListItemShimmer(),
          const SongListItemShimmer(),
          const SongListItemShimmer(),
        ],
      ),
    );
  }
}
