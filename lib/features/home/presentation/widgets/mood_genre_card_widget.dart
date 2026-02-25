import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/home/domain/entities/mood_genre.dart';

/// Widget para mostrar una categoría de mood/genre
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar una card de categoría
class MoodGenreCardWidget extends StatelessWidget {
  final MoodGenre moodGenre;

  const MoodGenreCardWidget({super.key, required this.moodGenre});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(MoodGenreRoute(params: moodGenre.params));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            moodGenre.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
