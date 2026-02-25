import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/main.dart';
import 'package:music_app/features/player/presentation/widgets/player_backdrop_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_header_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_error_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_artwork_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_info_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_progress_bar_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_metadata_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_controls_widget.dart';
import 'package:music_app/features/player/presentation/widgets/player_shimmer_widgets.dart';
import 'package:music_app/features/player/presentation/widgets/player_similar_songs_widget.dart';

@RoutePage()
class PlayerScreen extends StatefulWidget {
  final NowPlayingData nowPlayingData;

  const PlayerScreen({super.key, required this.nowPlayingData});

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

              return Stack(
                children: [
                  // Backdrop difuminado
                  PlayerBackdropWidget(thumbnail: currentTrack.bestThumbnail),

                  // Contenido con CustomScrollView
                  CustomScrollView(
                    slivers: [
                      // Header
                      const SliverToBoxAdapter(child: PlayerHeaderWidget()),

                      // Error message
                      if (hasError && errorMessage != null)
                        SliverToBoxAdapter(
                          child: PlayerErrorWidget(message: errorMessage),
                        ),

                      // Contenido principal
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // Artwork
                              PlayerArtworkWidget(
                                thumbnail: currentTrack.bestThumbnail,
                                videoId: currentTrack.videoId,
                                isLoading: isLoading,
                                isBuffering: isBuffering,
                              ),
                              const SizedBox(height: 16),

                              // Info (título, artista, álbum)
                              PlayerInfoWidget(
                                track: currentTrack,
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: 32),

                              // Progress bar
                              PlayerProgressBarWidget(
                                position: state is PlayerBlocLoaded
                                    ? state.position
                                    : Duration.zero,
                                duration:
                                    state is PlayerBlocLoaded &&
                                        state.duration.inSeconds > 0
                                    ? state.duration
                                    : Duration(
                                        seconds: currentTrack.durationSeconds,
                                      ),
                                onSeek: state is PlayerBlocLoaded
                                    ? (seekPosition) {
                                        context.read<PlayerBlocBloc>().add(
                                          SeekEvent(seekPosition),
                                        );
                                      }
                                    : null,
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: 24),

                              // Metadata
                              PlayerMetadataWidget(
                                track: currentTrack,
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: 32),

                              // Controles de reproducción
                              if (isLoading)
                                const PlaybackControlsShimmer()
                              else if (state is PlayerBlocLoaded)
                                PlayerControlsWidget(
                                  isPlaying: state.isPlaying,
                                  canPlayNext: state.canPlayNext,
                                  canPlayPrevious: state.canPlayPrevious,
                                  isShuffleEnabled: state.isShuffleEnabled,
                                  loopMode: state.loopMode,
                                  onPlayPause: () {
                                    context.read<PlayerBlocBloc>().add(
                                      const PlayPauseToggleEvent(),
                                    );
                                  },
                                  onNext: () {
                                    context.read<PlayerBlocBloc>().add(
                                      const NextTrackEvent(),
                                    );
                                  },
                                  onPrevious: () {
                                    context.read<PlayerBlocBloc>().add(
                                      const PreviousTrackEvent(),
                                    );
                                  },
                                  onShuffle: () {
                                    context.read<PlayerBlocBloc>().add(
                                      const ToggleShuffleEvent(),
                                    );
                                  },
                                  onRepeat: () {
                                    final nextLoopMode = _getNextLoopMode(
                                      state.loopMode,
                                    );
                                    context.read<PlayerBlocBloc>().add(
                                      SetLoopModeEvent(nextLoopMode),
                                    );
                                  },
                                )
                              else
                                PlayerControlsWidget(
                                  isPlaying: false,
                                  canPlayNext: false,
                                  canPlayPrevious: false,
                                  isShuffleEnabled: false,
                                  loopMode: LoopMode.off,
                                  onPlayPause: null,
                                  onNext: null,
                                  onPrevious: null,
                                  onShuffle: null,
                                  onRepeat: null,
                                ),
                              const SizedBox(height: 32),

                              // Connect to device
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.devices,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Connect to a device',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Songs similar to this
                              const PlayerSimilarSongsWidget(),
                            ],
                          ),
                        ),
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

  /// Obtiene el siguiente modo de repetición
  LoopMode _getNextLoopMode(LoopMode current) {
    switch (current) {
      case LoopMode.off:
        return LoopMode.one;
      case LoopMode.one:
        return LoopMode.all;
      case LoopMode.all:
        return LoopMode.off;
    }
  }
}
