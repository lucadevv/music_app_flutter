import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';
import 'package:music_app/features/recently_played/presentation/widgets/molecules/song_item_molecule.dart';

class RecentlyPlayedSongsOrganism extends StatelessWidget {
  final List<RecentlyPlayedSong> songs;
  final NowPlayingData Function(RecentlyPlayedSong) onPlaySong;

  const RecentlyPlayedSongsOrganism({
    required this.songs, required this.onPlaySong, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final song = songs[index];
        return SongItemMolecule(
          song: song,
          onTap: () => _handlePlaySong(context, song),
        );
      }, childCount: songs.length),
    );
  }

  void _handlePlaySong(BuildContext context, RecentlyPlayedSong song) {
    final nowPlayingData = onPlaySong(song);
    context.router.push(
      PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: true),
    );
  }
}
