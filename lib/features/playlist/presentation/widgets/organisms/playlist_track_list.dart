import 'package:flutter/material.dart';
import 'package:music_app/features/playlist/domain/entities/playlist_track.dart';
import 'package:music_app/features/playlist/presentation/widgets/atoms/empty_playlist_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/atoms/playlist_search_result_empty.dart';
import 'package:music_app/features/playlist/presentation/widgets/organisms/playlist_track_item_widget.dart';

class PlaylistTrackList extends StatelessWidget {
  final List<PlaylistTrack> tracks;
  final String searchQuery;
  final String playlistId;

  const PlaylistTrackList({
    required this.tracks,
    required this.searchQuery,
    required this.playlistId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final filterQueryTextEmpty = searchQuery.isEmpty;

    if (!filterQueryTextEmpty && tracks.isEmpty) {
      return PlaylistSearchResultEmpty(searchQuery: searchQuery);
    }

    if (tracks.isEmpty) {
      return const SliverFillRemaining(child: EmptyPlaylistWidget());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final track = tracks[index];
        return PlaylistTrackItemWidget(
          track: track,
          allTracks: tracks,
          playlistId: playlistId,
        );
      }, childCount: tracks.length),
    );
  }
}
