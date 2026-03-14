import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Widget para mostrar el estado de carga con shimmer
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar el estado de carga
class MoodGenreLoadingWidget extends StatelessWidget {
  const MoodGenreLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // AppBar con shimmer (botón volver + título)
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Shimmer.fromColors(
              baseColor: AppColorsDark.surfaceContainerHigh,
              highlightColor: AppColorsDark.surfaceContainerHighest,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            flexibleSpace: Shimmer.fromColors(
              baseColor: AppColorsDark.surfaceContainerHigh,
              highlightColor: AppColorsDark.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(56, 16, 24, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 150,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Grid de playlists shimmer
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Shimmer.fromColors(
                    baseColor: AppColorsDark.surfaceContainerHigh,
                    highlightColor: AppColorsDark.surfaceContainerHighest,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                childCount: 6,
              ),
            ),
          ),

          // Más items para llenar la pantalla
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Shimmer.fromColors(
                    baseColor: AppColorsDark.surfaceContainerHigh,
                    highlightColor: AppColorsDark.surfaceContainerHighest,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                childCount: 6,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
