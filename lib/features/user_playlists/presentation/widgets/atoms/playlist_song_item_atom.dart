import 'package:flutter/material.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';

class PlaylistSongItemAtom extends StatelessWidget {
  final String videoId;
  final String title;
  final String artist;
  final int? duration;
  final String? thumbnail;
  final VoidCallback onTap;

  const PlaylistSongItemAtom({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.onTap,
    this.duration,
    this.thumbnail,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SongListItem(
      title: title,
      artist: artist,
      thumbnail: thumbnail,
      onTap: onTap,
      trailing: IconButton(
        icon: Icon(
          Icons.more_vert,
          color: AppColorsDark.onSurface.withValues(alpha: 0.6),
        ),
        onPressed: () {
          SongOptionsBottomSheet.show(
            context: context,
            song: SongOptionsData(
              videoId: videoId,
              title: title,
              artist: artist,
              thumbnail: thumbnail,
              durationSeconds: duration,
              isFavorite: false,
            ),
          );
        },
      ),
    );
  }
}
