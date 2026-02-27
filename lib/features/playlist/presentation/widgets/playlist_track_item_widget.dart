import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/main.dart';
import '../../domain/entities/playlist_track.dart';

class PlaylistTrackItemWidget extends StatelessWidget {
  final PlaylistTrack track;
  final int index;
  final List<PlaylistTrack> allTracks;

  const PlaylistTrackItemWidget({
    super.key,
    required this.track,
    required this.index,
    required this.allTracks,
  });

  String _getArtistsNames() {
    if (track.artists.isEmpty) return 'Unknown Artist';
    return track.artists.map((artist) => artist.name).join(', ');
  }

  NowPlayingData _toNowPlayingData() {
    return NowPlayingData.fromPlaylistTrack(track);
  }

  bool _isPlaylistLoaded(PlayerBlocState playerState, List<PlaylistTrack> allTracks) {
    if (playerState is! PlayerBlocLoaded) return false;
    if (playerState.playlist.isEmpty) return false;

    final currentPlaylistVideoIds = allTracks
        .where((track) =>
            track.videoId != null &&
            track.videoId!.isNotEmpty &&
            track.isAvailable)
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
    final thumbnail = track.thumbnail ??
        (track.thumbnails.isNotEmpty ? track.thumbnails.last : null);

    final isDisabled =
        !track.isAvailable || track.videoId == null || track.videoId!.isEmpty;
    final opacity = isDisabled ? 0.5 : 1.0;

    return BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
      bloc: getIt<PlayerBlocBloc>(),
      builder: (context, playerState) {
        final isCurrentlyPlaying =
            playerState is PlayerBlocLoaded &&
            playerState.currentTrack != null &&
            playerState.currentTrack!.videoId == track.videoId &&
            playerState.isPlaying;

        final isCurrentTrack =
            playerState is PlayerBlocLoaded &&
            playerState.currentTrack != null &&
            playerState.currentTrack!.videoId == track.videoId;

        final isPlaylistLoaded = _isPlaylistLoaded(playerState, allTracks);

        return Opacity(
          opacity: opacity,
          child: GestureDetector(
            onTap: isDisabled
                ? null
                : () {
                    if (isPlaylistLoaded) {
                      if (playerState is PlayerBlocLoaded) {
                        final trackIndex = playerState.playlist.indexWhere(
                          (t) => t.videoId == track.videoId,
                        );
                        if (trackIndex >= 0) {
                          getIt<PlayerBlocBloc>().add(PlayTrackAtIndexEvent(trackIndex));
                        }
                      }
                    } else {
                      context.router.push(PlayerRoute(nowPlayingData: _toNowPlayingData()));
                    }
                  },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrentTrack
                    ? AppColorsDark.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isCurrentTrack
                    ? Border.all(
                        color: AppColorsDark.primary.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: isCurrentlyPlaying
                        ? Icon(Icons.equalizer, color: AppColorsDark.primary, size: 24)
                        : isCurrentTrack
                            ? Icon(Icons.pause_circle_filled, color: AppColorsDark.primary, size: 24)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: isDisabled ? 0.3 : 0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                  ),
                  const SizedBox(width: 16),
                  Hero(
                    tag: 'playlist_track_${track.videoId ?? index}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: thumbnail != null
                          ? CachedNetworkImage(
                              imageUrl: thumbnail.url,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 64,
                                height: 64,
                                color: AppColorsDark.primaryContainer,
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColorsDark.primary),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 64,
                                height: 64,
                                color: AppColorsDark.primaryContainer,
                                child: Icon(Icons.music_note, color: AppColorsDark.primary, size: 32),
                              ),
                            )
                          : Container(
                              width: 64,
                              height: 64,
                              color: AppColorsDark.primaryContainer,
                              child: Icon(Icons.music_note, color: AppColorsDark.primary, size: 32),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: isDisabled
                              ? null
                              : () => context.router.push(PlayerRoute(nowPlayingData: _toNowPlayingData())),
                          child: Text(
                            track.title,
                            style: TextStyle(
                              color: isCurrentTrack
                                  ? AppColorsDark.primary
                                  : Colors.white.withValues(alpha: isDisabled ? 0.3 : 1.0),
                              fontSize: 16,
                              fontWeight: isCurrentTrack ? FontWeight.w600 : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getArtistsNames(),
                          style: TextStyle(
                            color: isCurrentTrack
                                ? AppColorsDark.primary.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: isDisabled ? 0.2 : 0.6),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    track.duration,
                    style: TextStyle(
                      color: isCurrentTrack
                          ? AppColorsDark.primary.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: isDisabled ? 0.3 : 0.6),
                      fontSize: 14,
                      fontWeight: isCurrentTrack ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FavoriteButton(
                    videoId: track.videoId ?? '',
                    size: 20,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: isCurrentTrack
                          ? AppColorsDark.primary
                          : Colors.white.withValues(alpha: isDisabled ? 0.3 : 0.6),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
