import 'package:flutter/material.dart';
import 'package:music_app/core/widgets/category_chip.dart';
import 'package:music_app/features/home/domain/entities/mood_genre.dart';

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
    // Collect specific names to match design or use actual data.
    // The design shows 'All', 'Relax', 'Sad', 'Party', 'Romance'.
    // We will inject 'All' as the first item manually.
    final allCategories = ['All', ...widget.moods.map((e) => e.title), ...widget.genres.map((e) => e.title)];
    
    // In case there are no items, we fallback to hardcoded to match design visual
    final displayCategories = allCategories.length > 1 
        ? allCategories 
        : ['All', 'Relax', 'Sad', 'Party', 'Romance', 'Focus'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Categories',
                style: TextStyle(
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
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
