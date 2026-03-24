import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/l10n/app_localizations.dart';

class PlaylistActionButtonsMolecule extends StatelessWidget {
  final String playlistId;
  final bool isCurrentPlaylist;
  final bool isPlaying;
  final bool hasCurrentTrack;
  final VoidCallback onPlayPause;
  final VoidCallback onPlayAll;

  const PlaylistActionButtonsMolecule({
    required this.playlistId,
    required this.isCurrentPlaylist,
    required this.isPlaying,
    required this.hasCurrentTrack,
    required this.onPlayPause,
    required this.onPlayAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<
      PlayerBlocBloc,
      PlayerBlocState,
      ({String? sourceId, bool isPlaying, bool hasCurrentTrack})
    >(
      selector: (state) => (
        sourceId: state.sourceId,
        isPlaying: state.isPlaying,
        hasCurrentTrack: state.hasCurrentTrack,
      ),
      builder: (context, playerData) {
        final isCurrentPlaylist = playerData.sourceId == playlistId;
        final isPlaying = playerData.isPlaying;
        final hasCurrentTrack = playerData.hasCurrentTrack;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (isCurrentPlaylist && hasCurrentTrack) {
                    context.read<PlayerBlocBloc>().add(
                      const PlayPauseToggleEvent(),
                    );
                  } else {
                    onPlayAll();
                  }
                },
                icon: Icon(
                  isCurrentPlaylist && isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                label: Text(
                  isCurrentPlaylist && isPlaying ? l10n.pause : l10n.play,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsDark.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
