import 'package:flutter/material.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import '../molecules/queue_item.dart';
import 'queue_empty_view.dart';

/// Organism: Queue list showing upcoming tracks
class QueueList extends StatelessWidget {
  final List<NowPlayingData> playlist;
  final int currentIndex;
  final String emptyLabel;
  final void Function(NowPlayingData track, int index) onTrackTap;
  final void Function(int index) onTrackRemove;

  const QueueList({
    required this.playlist,
    required this.currentIndex,
    required this.emptyLabel,
    required this.onTrackTap,
    required this.onTrackRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (playlist.isEmpty) {
      return QueueEmptyView(title: emptyLabel);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: playlist.length,
      itemBuilder: (context, index) {
        // Skip current track
        if (index == currentIndex) {
          return const SizedBox.shrink();
        }

        final track = playlist[index];

        return QueueItem(
          track: track,
          onTap: () => onTrackTap(track, index),
          onRemove: () => onTrackRemove(index),
        );
      },
    );
  }
}
