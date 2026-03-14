import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'home_shimmer.dart';

/// Widget para mostrar el estado de carga del home con shimmer
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar el estado de carga con shimmer
class HomeLoadingWidget extends StatelessWidget {
  const HomeLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header con saludo shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.white.withValues(alpha: 0.1),
                  highlightColor: Colors.white.withValues(alpha: 0.2),
                  child: Container(
                    height: 16,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.white.withValues(alpha: 0.1),
                  highlightColor: Colors.white.withValues(alpha: 0.2),
                  child: Container(
                    height: 28,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Fila de categorías (Moods & Genres) en la parte SUPERIOR (Empatando con CategoriesRowWidget)
        const SliverToBoxAdapter(child: CategoriesRowShimmer()),

        // Sección shimmer (Quick picks o análogos)
        const SliverToBoxAdapter(child: SectionTitleShimmer()),

        // Cards shimmer horizontales
        const SliverToBoxAdapter(child: SongCardsShimmer()),

        // Otra sección shimmer (Trending)
        const SliverToBoxAdapter(child: SectionTitleShimmer()),

        // Más cards shimmer
        const SliverToBoxAdapter(child: SongCardsShimmer()),


        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
