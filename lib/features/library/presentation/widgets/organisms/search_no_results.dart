import 'package:flutter/material.dart';

/// Widget que muestra cuando no hay resultados de búsqueda.
class SearchNoResults extends StatelessWidget {
  final String searchQuery;

  const SearchNoResults({required this.searchQuery, super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$searchQuery"',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
