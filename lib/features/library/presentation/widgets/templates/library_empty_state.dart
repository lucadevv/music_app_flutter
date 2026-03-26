import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

class LibraryEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onExplore;

  const LibraryEmptyState({
    required this.message,
    required this.onExplore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.library_music_outlined,
            size: 64,
            color: AppColorsDark.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: AppColorsDark.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onExplore,
            child: Text(AppLocalizations.of(context)!.exploreMusic),
          ),
        ],
      ),
    );
  }
}
