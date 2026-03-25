import 'package:flutter/material.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/presentation/widgets/atoms/atoms.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';

/// Molécula: Item de canción en la lista del álbum
class AlbumSongItem extends StatelessWidget {
  final AlbumSong song;
  final VoidCallback? onTap;

  const AlbumSongItem({required this.song, super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SongListItemWithTrailing(
        title: song.title,
        artist: '',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SongDurationText(duration: song.formattedDuration),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              onPressed: () => _showSongOptions(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSongOptions(BuildContext context) {
    SongOptionsBottomSheet.show(
      context: context,
      song: SongOptionsData(
        videoId: song.videoId,
        title: song.title,
        artist: '',
        thumbnail: song.thumbnail,
        durationSeconds: song.durationSeconds,
        isFavorite: false,
      ),
    );
  }
}
