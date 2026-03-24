import 'package:flutter/material.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';
import 'package:music_app/features/recently_played/presentation/widgets/atoms/song_trailing_icon_atom.dart';

class SongItemMolecule extends StatelessWidget {
  final RecentlyPlayedSong song;
  final VoidCallback onTap;

  const SongItemMolecule({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SongListItemWithTrailing(
      title: song.title,
      artist: song.artist,
      thumbnail: song.thumbnail,
      trailing: const SongTrailingIconAtom(),
      onTap: onTap,
    );
  }
}
