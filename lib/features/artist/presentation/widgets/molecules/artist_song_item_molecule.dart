import 'package:flutter/material.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';

class ArtistSongItemMolecule extends StatelessWidget {
  final ArtistSong song;
  final int index;
  final VoidCallback onTap;

  const ArtistSongItemMolecule({
    super.key,
    required this.song,
    required this.index,
    required this.onTap,
  });

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
            Text(
              song.formattedDuration,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
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
