import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class CategoriesGridWidget extends StatelessWidget {
  const CategoriesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(
            'Browse all',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final categories = ['TAMIL', 'DANCE', 'PUNK', 'POP'];
              return _CategoryCard(
                name: categories[index % categories.length],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;

  const _CategoryCard({required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColorsDark.primary,
      AppColorsDark.secondary,
      AppColorsDark.tertiary,
      AppColorsDark.primaryContainer,
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors[name.length % colors.length].withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
