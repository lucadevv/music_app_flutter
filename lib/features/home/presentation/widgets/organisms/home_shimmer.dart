import 'package:flutter/material.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';
import 'package:shimmer/shimmer.dart';

/// Widgets de shimmer para el home
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar placeholders de carga con shimmer

/// Shimmer para la fila de Categorías/Moods (Horizontal Chips)
class CategoriesRowShimmer extends StatelessWidget {
  const CategoriesRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.white.withValues(alpha: 0.1),
                highlightColor: Colors.white.withValues(alpha: 0.2),
                child: Container(
                  height: 20,
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.white.withValues(alpha: 0.1),
                highlightColor: Colors.white.withValues(alpha: 0.2),
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.white.withValues(alpha: 0.1),
                highlightColor: Colors.white.withValues(alpha: 0.2),
                child: Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), // Chips are pill-shaped
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Shimmer para el GridView de categorías (Sliver Version)
class MoodGenresShimmer extends StatelessWidget {
  const MoodGenresShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.white.withValues(alpha: 0.1),
              highlightColor: Colors.white.withValues(alpha: 0.2),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          childCount: 9, // Mostrar 9 items de shimmer (3 filas x 3 columnas)
        ),
      ),
    );
  }
}

/// Shimmer para cards de canciones horizontales
class SongCardsShimmer extends StatelessWidget {
  const SongCardsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          214, // Exact height of the real SongCardWidget (cover + padding + text base)
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.white.withValues(alpha: 0.1),
                    highlightColor: Colors.white.withValues(alpha: 0.2),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.white.withValues(alpha: 0.1),
                        highlightColor: Colors.white.withValues(alpha: 0.2),
                        child: Container(
                          height: 14,
                          width: double.infinity,
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
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Shimmer para items de lista vertical
class SongListItemsShimmer extends StatelessWidget {
  const SongListItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const SongListItemShimmer(); // Uses the Phase 5 universally calibrated Shimmer Widget
      },
    );
  }
}

/// Shimmer para el título de sección
class SectionTitleShimmer extends StatelessWidget {
  const SectionTitleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.2),
        child: Container(
          height: 20,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
