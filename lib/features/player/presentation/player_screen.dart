import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/presentation/widgets/lyrics_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_artwork_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_backdrop_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_controls_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_error_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_header_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_info_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_progress_bar_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_shimmer_widgets.dart';
import 'package:music_app/features/player/presentation/widgets/player_similar_songs_widget.dart';
import 'package:music_app/main.dart';

@RoutePage()
class PlayerScreen extends StatefulWidget {
  final NowPlayingData nowPlayingData;

  const PlayerScreen({required this.nowPlayingData, super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = getIt<PlayerBlocBloc>();
      final state = bloc.state;

      // Si la canción actual ya es la que se quiere reproducir, no hacer nada
      if (state is PlayerBlocLoaded &&
          state.currentTrack?.videoId == widget.nowPlayingData.videoId) {
        return;
      }

      // Verificar si la canción está en la playlist cargada
      if (state is PlayerBlocLoaded && state.playlist.isNotEmpty) {
        final trackIndex = state.playlist.indexWhere(
          (track) => track.videoId == widget.nowPlayingData.videoId,
        );

        // Si la canción está en la playlist cargada, solo cambiar el índice
        if (trackIndex >= 0) {
          bloc.add(PlayTrackAtIndexEvent(trackIndex));
          return;
        }
      }

      // Si la canción no está en la playlist cargada, cargar solo esa canción
      bloc.add(LoadTrackEvent(widget.nowPlayingData));
    });
  }

  @override
  Widget build(BuildContext context) {
  
    return BlocProvider<PlayerBlocBloc>.value(
      value: getIt<PlayerBlocBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: SafeArea(
          child: BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
              buildWhen: (previous, current) {
              // Siempre reconstruir si el estado cambió significativamente
              if (previous.runtimeType != current.runtimeType) {
                return true;
              }
              // Si ambos son PlayerBlocLoaded, reconstruir si cambió algo importante
              if (previous is PlayerBlocLoaded && current is PlayerBlocLoaded) {
                return previous.position != current.position ||
                    previous.duration != current.duration ||
                    previous.playbackState != current.playbackState ||
                    previous.currentTrack?.videoId !=
                        current.currentTrack?.videoId ||
                    previous.currentIndex != current.currentIndex ||
                    previous.isLoading != current.isLoading ||
                    previous.playlist.length != current.playlist.length;
              }
              return true;
            },
            builder: (context, state) {
              final currentTrack = state is PlayerBlocLoaded
                  ? (state.currentTrack ?? widget.nowPlayingData)
                  : widget.nowPlayingData;

              final isLoading = state is PlayerBlocLoaded && state.isLoading;
              final isBuffering =
                  state is PlayerBlocLoaded && state.isBuffering;
              final hasError = state is PlayerBlocLoaded && state.hasError;
              final errorMessage = state is PlayerBlocLoaded
                  ? state.error
                  : null;

              // Get playback state values
              final isPlaying = state is PlayerBlocLoaded 
                  ? state.isPlaying 
                  : false;
              final canPlayNext = state is PlayerBlocLoaded 
                  ? state.canPlayNext 
                  : false;
              final canPlayPrevious = state is PlayerBlocLoaded 
                  ? state.canPlayPrevious 
                  : false;
              final isShuffleEnabled = state is PlayerBlocLoaded 
                  ? state.isShuffleEnabled 
                  : false;
              final repeatMode = state is PlayerBlocLoaded 
                  ? state.loopMode 
                  : LoopMode.off;

              return Stack(
                children: [
                  // Backdrop difuminado
                  PlayerBackdropWidget(thumbnail: currentTrack.highResThumbnail),

                  // Contenido con CustomScrollView
                  CustomScrollView(
                    slivers: [
                      // Header con botón de cerrar
                      const SliverToBoxAdapter(
                        child: PlayerHeaderWidget(),
                      ),

                      // Info de la canción
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              // Artwork
                              PlayerArtworkWidget(
                                thumbnail: currentTrack.highResThumbnail,
                                videoId: currentTrack.videoId,
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: 24),
                              // Info
                              PlayerInfoWidget(
                                track: currentTrack,
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: 16),
                              // Progress bar
                              PlayerProgressBarWidget(
                                position: state is PlayerBlocLoaded
                                    ? state.position
                                    : Duration.zero,
                                duration: state is PlayerBlocLoaded
                                    ? state.duration
                                    : Duration.zero,
                                onSeek: (position) => context.read<PlayerBlocBloc>().add(SeekEvent(position)),
                              ),
                              const SizedBox(height: 16),
                              // Controls
                              PlayerControlsWidget(
                                isPlaying: isPlaying,
                                canPlayNext: canPlayNext,
                                canPlayPrevious: canPlayPrevious,
                                isShuffleEnabled: isShuffleEnabled,
                                loopMode: repeatMode,
                                onPlayPause: () => context.read<PlayerBlocBloc>().add(const PlayPauseToggleEvent()),
                                onNext: () => context.read<PlayerBlocBloc>().add(const NextTrackEvent()),
                                onPrevious: () => context.read<PlayerBlocBloc>().add(const PreviousTrackEvent()),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      // Playlist
                      if (!hasError && !isLoading && state is PlayerBlocLoaded && state.playlist.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _PlaylistWidget(
                            playlist: state.playlist,
                            currentIndex: state.currentIndex,
                            onTrackTap: (index) {
                              context.read<PlayerBlocBloc>().add(PlayTrackAtIndexEvent(index));
                            },
                          ),
                        ),

                      // Similar songs
                      if (!hasError && !isLoading)
                        SliverToBoxAdapter(
                          child: PlayerSimilarSongsWidget(
                            videoId: currentTrack.videoId,
                          ),
                        ),

                      // Lyrics
                      if (!hasError && !isLoading)
                        SliverToBoxAdapter(
                          child: LyricsWidget(
                            videoId: currentTrack.videoId,
                          ),
                        ),

                      // Error widget
                      if (hasError)
                        SliverToBoxAdapter(
                          child: PlayerErrorWidget(
                            message: errorMessage ?? 'Unknown error',
                          ),
                        ),

                      // Loading shimmer
                      if (isLoading || isBuffering)
                        const SliverToBoxAdapter(
                          child: PlayerShimmerWidget(),
                        ),

                      // Bottom padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar la playlist en la pantalla del reproductor
class _PlaylistWidget extends StatelessWidget {
  final List<NowPlayingData> playlist;
  final int? currentIndex;
  final void Function(int index) onTrackTap;

  const _PlaylistWidget({
    required this.playlist,
    required this.currentIndex,
    required this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Header
          Row(
            children: [
              const Icon(
                Icons.queue_music,
                color: Colors.white70,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Playlist',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                '${playlist.length} songs',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Playlist items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              final track = playlist[index];
              final isCurrentTrack = index == currentIndex;

              return _PlaylistItemWidget(
                track: track,
                index: index,
                isCurrentTrack: isCurrentTrack,
                onTap: () => onTrackTap(index),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Widget para un item individual de la playlist
class _PlaylistItemWidget extends StatelessWidget {
  final NowPlayingData track;
  final int index;
  final bool isCurrentTrack;
  final VoidCallback onTap;

  const _PlaylistItemWidget({
    required this.track,
    required this.index,
    required this.isCurrentTrack,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentTrack ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 48,
                height: 48,
                child: CachedNetworkImage(
                  imageUrl: track.highResThumbnail.url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white54,
                      size: 24,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white54,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: TextStyle(
                      color: isCurrentTrack ? const Color(0xFF1DB954) : Colors.white,
                      fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artistsNames,
                    style: TextStyle(
                      color: isCurrentTrack ? const Color(0xFF1DB954).withValues(alpha: 0.8) : Colors.white54,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Duration
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                track.duration,
                style: TextStyle(
                  color: isCurrentTrack ? const Color(0xFF1DB954) : Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
            // Playing indicator
            if (isCurrentTrack)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.equalizer,
                  color: Color(0xFF1DB954),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
