import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';

import '../animators/animated_stat_card_widget.dart';
import '../molecules/stat_card_widget.dart';

/// Organismo que representa la fila de estadísticas completas del usuario
class ProfileStatsRowWidget extends StatelessWidget {
  final ProfileState state;
  final double entryDelay;

  const ProfileStatsRowWidget({
    required this.state, super.key,
    this.entryDelay = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedStatCardWidget(
      delay: entryDelay,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: state.isLoadingStats
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColorsDark.primary,
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatCardWidget(
                    icon: Icons.favorite,
                    number: state.favoriteSongsCount.toString(),
                    label: l10n.songs,
                    onTap: () => context.router.push(const LikedSongsRoute()),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  StatCardWidget(
                    icon: Icons.playlist_play,
                    number: state.favoritePlaylistsCount.toString(),
                    label: l10n.playlists,
                    onTap: () {
                      // TODO: Implement navigation to playlists tab
                    },
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  StatCardWidget(
                    icon: Icons.download_done,
                    number: state.downloadedSongsCount.toString(),
                    label: l10n.offline,
                    onTap: () => context.router.push(const DownloadsRoute()),
                  ),
                ],
              ),
      ),
    );
  }
}
