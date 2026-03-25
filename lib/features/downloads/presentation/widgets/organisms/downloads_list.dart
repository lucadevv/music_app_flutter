import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/downloads/presentation/widgets/downloaded_song_item_widget.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

/// Organismo: DownloadsList
///
/// Lista de canciones descargadas con acciones de tap y delete.
class DownloadsList extends StatelessWidget {
  final List<DownloadedSong> downloadedSongs;
  final Set<String> downloadingIds;
  final Map<String, double> downloadProgress;
  final void Function(DownloadedSong) onSongTap;
  final void Function(DownloadedSong) onSongDelete;

  const DownloadsList({
    required this.downloadedSongs, required this.downloadingIds, required this.downloadProgress, required this.onSongTap, required this.onSongDelete, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: downloadedSongs.length,
        itemBuilder: (context, index) {
          final song = downloadedSongs[index];
          final isDownloading = downloadingIds.contains(song.videoId);
          final progress = downloadProgress[song.videoId] ?? 0.0;

          return DownloadedSongItemWidget(
            song: song,
            isDownloading: isDownloading,
            progress: progress,
            onTap: () => onSongTap(song),
            onDelete: () => onSongDelete(song),
          );
        },
      ),
    );
  }
}

/// Widget que incluye la lógica de navegación del DownloadsList.
class DownloadsListWithNavigation extends StatelessWidget {
  final List<DownloadedSong> downloadedSongs;
  final Set<String> downloadingIds;
  final Map<String, double> downloadProgress;
  final NowPlayingData Function(DownloadedSong) playDownloadedSong;
  final void Function(DownloadedSong) onDelete;

  const DownloadsListWithNavigation({
    required this.downloadedSongs, required this.downloadingIds, required this.downloadProgress, required this.playDownloadedSong, required this.onDelete, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: downloadedSongs.length,
        itemBuilder: (context, index) {
          final song = downloadedSongs[index];
          final isDownloading = downloadingIds.contains(song.videoId);
          final progress = downloadProgress[song.videoId] ?? 0.0;

          return DownloadedSongItemWidget(
            song: song,
            isDownloading: isDownloading,
            progress: progress,
            onTap: () {
              final nowPlayingData = playDownloadedSong(song);
              context.router.push(
                PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: true),
              );
            },
            onDelete: () => onDelete(song),
          );
        },
      ),
    );
  }
}
