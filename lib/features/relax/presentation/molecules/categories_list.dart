import 'package:flutter/material.dart';
import 'package:music_app/features/relax/presentation/atoms/category_chip.dart';
import 'package:music_app/l10n/app_localizations.dart';

class CategoriesList extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onCategorySelected;

  const CategoriesList({
    super.key,
    this.selectedIndex = 0,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      l10n.relax,
      l10n.workout,
      l10n.travel,
      l10n.focus,
      l10n.energize,
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return CategoryChip(
            label: categories[index],
            isSelected: index == selectedIndex,
          );
        },
      ),
    );
  }
}
