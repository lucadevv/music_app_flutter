import 'package:flutter/material.dart';
import 'package:music_app/core/utils/extension/sizedbox_extension.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';
import 'package:music_app/features/library/presentation/widgets/organisms/playlists_section.dart';
import 'package:music_app/features/library/presentation/widgets/organisms/search_no_results.dart';
import 'package:music_app/features/library/presentation/widgets/organisms/songs_section.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Contenido filtrado de la biblioteca basado en búsqueda.
class LibraryFilteredContent extends StatelessWidget {
  final String searchQuery;
  final List<PlaylistItem> allPlaylists;
  final List<FavoriteSong> favoriteSongs;
  final void Function(FavoriteSong song, AppLocalizations l10n) onShowOptions;

  const LibraryFilteredContent({
    required this.searchQuery,
    required this.allPlaylists,
    required this.favoriteSongs,
    required this.onShowOptions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final filteredPlaylists = searchQuery.isEmpty
        ? allPlaylists
        : allPlaylists.where((p) {
            final name = p.name.toLowerCase();
            return name.contains(searchQuery);
          }).toList();

    final filteredSongs = searchQuery.isEmpty
        ? favoriteSongs
        : favoriteSongs.where((s) {
            final title = s.title.toLowerCase();
            final artist = s.artist.toLowerCase();
            return title.contains(searchQuery) || artist.contains(searchQuery);
          }).toList();

    if (searchQuery.isNotEmpty &&
        filteredPlaylists.isEmpty &&
        filteredSongs.isEmpty) {
      return SearchNoResults(searchQuery: searchQuery);
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredPlaylists.isNotEmpty)
            PlaylistsSection(
              playlists: filteredPlaylists,
              totalPlaylists: filteredPlaylists.length,
              showViewAll: false,
              useSliver: false,
            ),
          if (filteredSongs.isNotEmpty)
            SongsSection(
              songs: filteredSongs,
              showViewAll: false,
              usePlayAllFromIndex: true,
              onShowOptions: onShowOptions,
            ),
          60.spaceh,
        ],
      ),
    );
  }
}
