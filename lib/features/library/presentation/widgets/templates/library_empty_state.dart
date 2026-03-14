import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

class LibraryEmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onExplore;

  const LibraryEmptyState({
    required this.l10n,
    required this.onExplore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColorsDark.primary.withValues(alpha: 0.15),
                  AppColorsDark.primary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.library_music,
              size: 64,
              color: AppColorsDark.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.yourLibraryIsEmpty,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.songsAndPlaylistsWillAppearHere,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onExplore,
            icon: const Icon(Icons.explore),
            label: Text(l10n.exploreMusic),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsDark.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
