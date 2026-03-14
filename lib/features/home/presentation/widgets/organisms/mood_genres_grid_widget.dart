import 'package:flutter/material.dart';
import 'package:music_app/features/home/domain/entities/mood_genre.dart';
import '../molecules/mood_genre_card_widget.dart';

/// Widget para mostrar el grid de categorías (moods_genres)
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar el grid de categorías
class MoodGenresGridWidget extends StatelessWidget {
  final List<MoodGenre> moods;
  final List<MoodGenre> genres;

  const MoodGenresGridWidget({
    required this.moods,
    required this.genres,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Combinar moods y genres para mostrar en el grid
    final allCategories = [...moods, ...genres];

    if (allCategories.isEmpty) {
      // Retornar un Sliver vacío en lugar de SizedBox.shrink()
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.5,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final moodGenre = allCategories[index];
          return MoodGenreCardWidget(moodGenre: moodGenre);
        }, childCount: allCategories.length),
      ),
    );
  }
}
