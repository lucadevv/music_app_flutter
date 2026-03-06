import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';
import '../../domain/entities/playlist_track.dart';

class PlaylistTrackItemWidget extends StatelessWidget {
  final PlaylistTrack track;
  final List<PlaylistTrack> allTracks;

  const PlaylistTrackItemWidget({
    required this.track, // ignore: always_put_required_named_parameters_first
    required this.allTracks,
    super.key,
  });

  String _getArtistsNames() {
    if (track.artists.isEmpty) return 'Unknown Artist';
    return track.artists.map((artist) => artist.name).join(', ');
  }

  NowPlayingData _toNowPlayingData() {
    return NowPlayingData.fromPlaylistTrack(track);
  }

  bool _isPlaylistLoaded(
    PlayerBlocState playerState,
    List<PlaylistTrack> allTracks,
  ) {
    if (playerState is! PlayerBlocState) return false;
    if (playerState.playlist.isEmpty) return false;

    final currentPlaylistVideoIds = allTracks
        .where(
          (track) =>
              track.videoId != null &&
              track.videoId!.isNotEmpty &&
              track.isAvailable,
        )
        .map((track) => track.videoId!)
        .toList();

    final loadedPlaylistVideoIds = playerState.playlist
        .where((track) => track.videoId.isNotEmpty)
        .map((track) => track.videoId)
        .toList();

    if (currentPlaylistVideoIds.length != loadedPlaylistVideoIds.length) {
      return false;
    }

    for (int i = 0; i < currentPlaylistVideoIds.length; i++) {
      if (currentPlaylistVideoIds[i] != loadedPlaylistVideoIds[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail =
        track.thumbnail ??
        (track.thumbnails.isNotEmpty ? track.thumbnails.last : null);

    final isDisabled =
        !track.isAvailable || track.videoId == null || track.videoId!.isEmpty;

    final playerBloc = context.read<PlayerBlocBloc>();

    return BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
      bloc: playerBloc,
      builder: (context, playerState) {
        // Mostrar indicador si es la canción actual (reproduciendo o en pausa)
        final isCurrentTrack =
            playerState is PlayerBlocState &&
            playerState.currentTrack != null &&
            playerState.currentTrack!.videoId == track.videoId;

        final isCurrentlyPlaying = isCurrentTrack && playerState.isPlaying;

        final isPlaylistLoaded = _isPlaylistLoaded(playerState, allTracks);

        return Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: SongListItemWithTrailing(
            title: track.title,
            artist: _getArtistsNames(),
            thumbnail: thumbnail?.url,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de reproducir o equalizer
                SizedBox(
                  width: 24,
                  child: isCurrentlyPlaying
                      ? const Icon(
                          Icons.equalizer,
                          color: AppColorsDark.primary,
                          size: 20,
                        )
                      : isCurrentTrack
                          ? Icon(
                              Icons.pause,
                              color: AppColorsDark.primary,
                              size: 20,
                            )
                          : Icon(
                              Icons.play_arrow,
                              color: Colors.white.withValues(
                                alpha: isDisabled ? 0.3 : 0.6,
                              ),
                              size: 20,
                            ),
                ),
                const SizedBox(width: 8),
                // Botón de favorito
                FavoriteButton(
                  videoId: track.videoId ?? '',
                  size: 20,
                  metadata: SongMetadata(
                    title: track.title,
                    artist: _getArtistsNames(),
                    thumbnail: thumbnail?.url,
                    duration: track.durationSeconds,
                  ),
                ),
                // Botón de más opciones
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withValues(
                      alpha: isDisabled ? 0.3 : 0.6,
                    ),
                    size: 20,
                  ),
                  onPressed: isDisabled
                      ? null
                      : () => _showTrackOptionsBottomSheet(context),
                ),
              ],
            ),
            onTap: isDisabled
                ? null
                : () {
                    // Reproducir solo esta canción (limpia la cola)
                    context.router.push(
                      PlayerRoute(
                        nowPlayingData: _toNowPlayingData(),
                        playAsSingle: true,
                      ),
                    );
                  },
          ),
        );
      },
    );
  }

  void _showTrackOptionsBottomSheet(BuildContext context) {
    SongOptionsBottomSheet.show(
      context: context,
      song: SongOptionsData(
        videoId: track.videoId ?? '',
        title: track.title,
        artist: _getArtistsNames(),
        thumbnail:
            track.thumbnail?.url ??
            (track.thumbnails.isNotEmpty ? track.thumbnails.last.url : null),
        streamUrl: track.streamUrl,
        durationSeconds: track.durationSeconds,
        isFavorite: track.inLibrary ?? false,
      ),
    );
  }
}
