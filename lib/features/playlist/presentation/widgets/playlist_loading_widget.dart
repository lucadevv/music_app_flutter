import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:shimmer/shimmer.dart';

/// Widget de carga con shimmer para la playlist
class PlaylistLoadingWidget extends StatelessWidget {
  const PlaylistLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App Bar con shimmer
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: Shimmer.fromColors(
            baseColor: AppColorsDark.surfaceContainerHigh,
            highlightColor: AppColorsDark.surfaceContainerHighest,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColorsDark.surfaceContainerHigh, AppColorsDark.surface],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(width: 250, height: 28, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 200, height: 14, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Action buttons shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColorsDark.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                ...List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColorsDark.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Songs list shimmer
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return Shimmer.fromColors(
              baseColor: AppColorsDark.surfaceContainerHigh,
              highlightColor: AppColorsDark.surfaceContainerHighest,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                leading: Container(width: 40, height: 20, color: Colors.white),
                title: Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                subtitle: Container(
                  width: 150,
                  height: 14,
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 8),
                ),
                trailing: Container(width: 40, height: 14, color: Colors.white),
              ),
            );
          }, childCount: 10),
        ),
      ],
    );
  }
}
