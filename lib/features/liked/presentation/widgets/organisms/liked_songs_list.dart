import 'package:flutter/material.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/library/library_service.dart';

class LikedSongsList extends StatelessWidget {
  final List<FavoriteSong> songs;
  final bool isLoadingMore;
  final bool hasMore;
  final void Function(FavoriteSong song)? onSongTap;
  final void Function(FavoriteSong song)? onRemove;

  const LikedSongsList({
    required this.songs,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onSongTap,
    this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        // Mostrar indicador de carga al final de la lista
        if (index == songs.length) {
          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColorsDark.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final song = songs[index];
        return SongListItemWithRemove(
          title: song.title,
          artist: song.artist,
          thumbnail: song.thumbnail,
          onTap: onSongTap != null ? () => onSongTap!(song) : null,
          onRemove: onRemove != null ? () => onRemove!(song) : null,
        );
      }, childCount: songs.length + (isLoadingMore || hasMore ? 1 : 0)),
    );
  }
}
