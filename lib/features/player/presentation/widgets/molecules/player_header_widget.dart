import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';

/// Widget para el header del reproductor
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar el header con botones de navegación
class PlayerHeaderWidget extends StatelessWidget {
  final String? playlistId;
  final String? playlistName;
  final int currentIndex;
  final int totalTracks;
  final String? currentVideoId;
  final String? currentTitle;
  final String? currentArtist;
  final String? currentThumbnail;
  final int? currentDuration;
  final bool isFavorite;

  const PlayerHeaderWidget({
    super.key,
    this.playlistId,
    this.playlistName,
    this.currentIndex = 0,
    this.totalTracks = 0,
    this.currentVideoId,
    this.currentTitle,
    this.currentArtist,
    this.currentThumbnail,
    this.currentDuration,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColorsDark.onSurface,
              size: 20,
            ),
            onPressed: () => context.router.pop(),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Music Player',
                  style: TextStyle(
                    color: AppColorsDark.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (playlistName != null)
                  Text(
                    playlistName!,
                    style: const TextStyle(
                      color: AppColorsDark.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                if (totalTracks > 0)
                  Text(
                    '${currentIndex + 1}/$totalTracks',
                    style: TextStyle(
                      color: AppColorsDark.onSurface.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentVideoId != null)
                IconButton(
                  icon: const Icon(
                    Icons.playlist_add,
                    color: AppColorsDark.onSurface,
                  ),
                  onPressed: () => _showAddToPlaylistSheet(context),
                ),
              IconButton(
                icon: const Icon(
                  Icons.queue_music,
                  color: AppColorsDark.onSurface,
                ),
                onPressed: () => context.router.push(const QueueRoute()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistSheet(BuildContext context) {
    if (currentVideoId == null) return;

    SongOptionsBottomSheet.show(
      context: context,
      song: SongOptionsData(
        videoId: currentVideoId!,
        title: currentTitle ?? '',
        artist: currentArtist ?? '',
        thumbnail: currentThumbnail,
        durationSeconds: currentDuration,
        isFavorite: isFavorite,
      ),
    );
  }
}
