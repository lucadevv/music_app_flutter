import 'package:flutter/material.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';

/// Widget de loading con shimmer para SearchScreen
class SearchLoadingView extends StatelessWidget {
  const SearchLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          // Trending artists shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: TextShimmer(width: 150, height: 24),
          ),
          SizedBox(height: 16),
          ArtistListItemShimmer(),
          ArtistListItemShimmer(),
          ArtistListItemShimmer(),
          
          SizedBox(height: 32),
          
          // Categories shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: TextShimmer(width: 150, height: 24),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: CategoriesGridShimmer(itemCount: 6, crossAxisCount: 2),
          ),
        ],
      ),
    );
  }
}
