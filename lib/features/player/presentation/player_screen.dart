import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/presentation/widgets/player_backdrop_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_header_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_error_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_artwork_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_info_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_progress_bar_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_controls_widget.dart';
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
              if (previous is PlayerBlocLoaded && current is PlayerBlocLoaded) {
                return previous.position != current.position ||
                    previous.duration != current.duration ||
                    previous.playbackState != current.playbackState ||
                    previous.currentTrack?.videoId !=
                        current.currentTrack?.videoId ||
                    previous.isLoading != current.isLoading;
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
                  PlayerBackdropWidget(thumbnail: currentTrack.bestThumbnail),

                  // Contenido con CustomScrollView
                  CustomScrollView(
                    slivers: [
                      // Header con botón de cerrar
                      const PlayerHeaderWidget(),

                      // Info de la canción
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              // Artwork
                              PlayerArtworkWidget(
                                thumbnail: currentTrack.bestThumbnail,
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
                              ),
                              const SizedBox(height: 16),
                              // Controls
                              PlayerControlsWidget(
                                isPlaying: isPlaying,
                                canPlayNext: canPlayNext,
                                canPlayPrevious: canPlayPrevious,
                                isShuffleEnabled: isShuffleEnabled,
                                loopMode: repeatMode,
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      // Similar songs
                      if (!hasError && !isLoading)
                        PlayerSimilarSongsWidget(
                          videoId: currentTrack.videoId,
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
