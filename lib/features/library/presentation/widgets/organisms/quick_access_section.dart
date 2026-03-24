import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/library/presentation/widgets/molecules/quick_access_chip.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Sección de acceso rápido a playlists y filtros comunes.
class QuickAccessSection extends StatelessWidget {
  final int totalSongs;
  final int totalPlaylists;
  final int totalGenres;

  const QuickAccessSection({
    required this.totalSongs,
    required this.totalPlaylists,
    required this.totalGenres,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Access',
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                QuickAccessChip(
                  icon: Icons.favorite,
                  label: l10n.likedSongs,
                  count: totalSongs,
                  onTap: () => context.router.push(const LikedSongsRoute()),
                ),
                QuickAccessChip(
                  icon: Icons.history,
                  label: l10n.recentlyPlayed,
                  count: 0,
                  onTap: () => context.router.push(const RecentlyPlayedRoute()),
                ),
                QuickAccessChip(
                  icon: Icons.playlist_play,
                  label: l10n.myPlaylists,
                  count: totalPlaylists,
                  onTap: () => context.router.push(const UserPlaylistsRoute()),
                ),
                QuickAccessChip(
                  icon: Icons.library_music,
                  label: l10n.genres,
                  count: totalGenres,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
