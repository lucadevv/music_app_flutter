import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/playlist/domain/entities/playlist_track.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';

class AddToPlaylistSongsBottomSheet extends StatelessWidget {
  final List<PlaylistTrack> tracks;

  const AddToPlaylistSongsBottomSheet({required this.tracks, super.key});

  static void show({
    required BuildContext context,
    required List<PlaylistTrack> tracks,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => AddToPlaylistSongsBottomSheet(tracks: tracks),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: AppColorsDark.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select a song to add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return _TrackItem(track: track);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackItem extends StatelessWidget {
  final PlaylistTrack track;

  const _TrackItem({required this.track});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColorsDark.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: track.thumbnails.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  track.thumbnails.last.url,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.music_note, color: Colors.white54),
      ),
      title: Text(
        track.title,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artists.map((a) => a.name).join(', '),
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pop(context);
        SongOptionsBottomSheet.show(
          context: context,
          song: SongOptionsData(
            videoId: track.videoId ?? '',
            title: track.title,
            artist: track.artists.map((a) => a.name).join(', '),
            thumbnail: track.thumbnails.isNotEmpty
                ? track.thumbnails.last.url
                : '',
            isFavorite: track.inLibrary ?? false,
            durationSeconds: track.durationSeconds,
          ),
        );
      },
    );
  }
}
