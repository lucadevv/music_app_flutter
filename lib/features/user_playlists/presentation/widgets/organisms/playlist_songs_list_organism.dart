import 'package:flutter/material.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/user_playlists/presentation/widgets/atoms/playlist_song_item_atom.dart';

class PlaylistSongsListOrganism extends StatelessWidget {
  final List<UserPlaylistSong> songs;
  final Function(int) onPlaySong;

  const PlaylistSongsListOrganism({
    required this.songs,
    required this.onPlaySong,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final song = songs[index];
        return PlaylistSongItemAtom(
          videoId: song.videoId,
          title: song.title,
          artist: song.artist,
          duration: song.duration,
          thumbnail: song.thumbnail,
          onTap: () => onPlaySong(index),
        );
      }, childCount: songs.length),
    );
  }
}
