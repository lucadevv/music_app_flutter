import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/song_list_item.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: _buildAppBar(context, l10n),
      body: BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
        builder: (context, state) {
          if (state is! PlayerBlocLoaded) {
            return _buildEmptyQueue(context, l10n);
          }

          return Column(
            children: [
              // Now playing
              _buildNowPlaying(context, state, l10n),

              // Up Next
              _buildUpNextHeader(context, l10n),

              // Queue list
              Expanded(
                child: _buildQueueList(context, state, l10n),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        onPressed: () => context.router.pop(),
      ),
      title: Text(
        l10n.queue,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Limpiar la playlist (usar LoadPlaylistEvent con lista vacía)
            final state = context.read<PlayerBlocBloc>().state;
            if (state is PlayerBlocLoaded && state.playlist.isNotEmpty) {
              context.read<PlayerBlocBloc>().add(
                const LoadPlaylistEvent(playlist: [], startIndex: 0),
              );
            }
          },
          child: Text(l10n.clear, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildEmptyQueue(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.queue_music, size: 64, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'No hay canciones en cola',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying(BuildContext context, PlayerBlocLoaded state, AppLocalizations l10n) {
    final track = state.currentTrack;
    if (track == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 56,
              height: 56,
              color: AppColorsDark.primaryContainer,
            child: track.bestThumbnail != null
              ? CachedNetworkImage(
                  imageUrl: track.bestThumbnail!.url,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => const Icon(Icons.music_note, color: AppColorsDark.primary),
                )
                  : const Icon(Icons.music_note, color: AppColorsDark.primary),
            ),
          ),
          const SizedBox(width: 16),

          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.nowPlaying,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  track.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  track.artistsNames,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Play/Pause button
          IconButton(
            icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
            onPressed: () => context.read<PlayerBlocBloc>().add(const PlayPauseToggleEvent()),
          ),
        ],
      ),
    );
  }

  Widget _buildUpNextHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            l10n.upNext,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text(l10n.autoRecommendations, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList(BuildContext context, PlayerBlocLoaded state, AppLocalizations l10n) {
    final queue = state.playlist;

    if (queue.isEmpty) {
      return Center(
        child: Text(
          'La cola está vacía',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        ),
      );
    }

    // Obtener el índice actual
    final currentIndex = state.currentIndex;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: queue.length,
      itemBuilder: (context, index) {
        // Saltar la canción actual
        if (index == currentIndex) {
          return const SizedBox.shrink();
        }

        final track = queue[index];
        // queueIndex no utilizado actualmente; lo eliminamos para evitar warnings

        return _QueueItemWidget(
          track: track,
          onTap: () {
            // Reproducir esta canción
            context.read<PlayerBlocBloc>().add(PlayTrackAtIndexEvent(index));
            // Navegar al reproductor
            context.router.push(PlayerRoute(nowPlayingData: track));
          },
          onRemove: () {
            // Eliminar de la playlist usando el evento existente
            context.read<PlayerBlocBloc>().add(RemoveFromPlaylistEvent(index));
          },
        );
      },
    );
  }
}

class _QueueItemWidget extends StatelessWidget {
  final NowPlayingData track;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _QueueItemWidget({
    required this.track,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SongListItemWithTrailing(
      title: track.title,
      artist: track.artistsNames,
      thumbnail: track.bestThumbnail?.url,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            track.formattedDuration,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.6), size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
