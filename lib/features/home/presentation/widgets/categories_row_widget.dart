import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/widgets/category_chip.dart';
import 'package:music_app/features/home/domain/entities/mood_genre.dart';
import 'package:music_app/l10n/app_localizations.dart';

class CategoriesRowWidget extends StatefulWidget {
  final List<MoodGenre> moods;
  final List<MoodGenre> genres;

  const CategoriesRowWidget({
    super.key,
    required this.moods,
    required this.genres,
  });

  @override
  State<CategoriesRowWidget> createState() => _CategoriesRowWidgetState();
}

class _CategoriesRowWidgetState extends State<CategoriesRowWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Combine moods and genres into a single list
    final allMoodGenres = [...widget.moods, ...widget.genres];
    
    // Create display categories with translated "All" as first item
    final displayCategories = <String>[l10n.all, ...allMoodGenres.map((e) => e.title)];
    
    // Fallback if no data
    final hasData = allMoodGenres.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.selectCategories,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: displayCategories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return CategoryChip(
                label: displayCategories[index],
                isSelected: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  
                  // Navigate based on selection
                  if (index == 0) {
                    // "All" - navigate to a general view or do nothing
                    // For now, we'll navigate to the first available mood/genre
                    if (hasData && allMoodGenres.first.params.isNotEmpty) {
                      context.router.push(MoodGenreRoute(params: allMoodGenres.first.params));
                    }
                  } else if (hasData) {
                    // Navigate to the selected mood/genre
                    final selectedIndex = index - 1; // -1 because "All" is at index 0
                    if (selectedIndex < allMoodGenres.length) {
                      final selectedMoodGenre = allMoodGenres[selectedIndex];
                      if (selectedMoodGenre.params.isNotEmpty) {
                        context.router.push(MoodGenreRoute(params: selectedMoodGenre.params));
                      }
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
