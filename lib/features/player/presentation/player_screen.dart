import 'package:auto_route/auto_route.dart';
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

    // Sincronizar canción al abrir PlayerScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<PlayerBlocBloc>();
      final state = bloc.state;

      if (state is PlayerBlocLoaded && state.playlist.isNotEmpty) {
        // Buscar si la canción está en la playlist
        final trackIndex = state.playlist.indexWhere(
          (t) => t.videoId == widget.nowPlayingData.videoId,
        );

        if (trackIndex >= 0 && state.playlist[trackIndex].streamUrl != null) {
          // Está en playlist con URL - reproducir ese índice
          bloc.add(PlayTrackAtIndexEvent(trackIndex));
        } else {
          // No está o sin URL - cargar canción
          bloc.add(LoadTrackEvent(widget.nowPlayingData));
        }
      } else {
        // Sin playlist - cargar canción
        bloc.add(LoadTrackEvent(widget.nowPlayingData));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
        builder: (context, state) {
          // Obtener datos del estado
          final isLoaded = state is PlayerBlocLoaded;
          
          final playlist = isLoaded ? state.playlist : <NowPlayingData>[];
          final currentIndex = isLoaded ? state.currentIndex : null;
          final currentTrackData = isLoaded 
              ? (state.currentTrack ?? widget.nowPlayingData)
              : widget.nowPlayingData;
          
          final isLoading = isLoaded && state.isLoading;
          final isBuffering = isLoaded && state.isBuffering;
          final hasError = isLoaded && state.hasError;
          final errorMessage = isLoaded ? state.error : null;
          
          final isPlaying = isLoaded ? state.isPlaying : false;
          final canPlayNext = isLoaded ? state.canPlayNext : false;
          final canPlayPrevious = isLoaded ? state.canPlayPrevious : false;
          final isShuffleEnabled = isLoaded ? state.isShuffleEnabled : false;
          final repeatMode = isLoaded ? state.loopMode : LoopMode.off;
          
          final position = isLoaded ? state.position : Duration.zero;
          final duration = isLoaded ? state.duration : Duration.zero;
    
          return Stack(
            children: [
              // Backdrop
              PlayerBackdropWidget(thumbnail: currentTrackData.highResThumbnail),
    
              // Contenido
              CustomScrollView(
                slivers: [
                  // Header
                  const SliverToBoxAdapter(
                    child: PlayerHeaderWidget(),
                  ),
    
                  // Carrusel o Artwork
                  SliverToBoxAdapter(
                    child: _PlayerCarousel(
                      playlist: playlist,
                      currentIndex: currentIndex ?? 0,
                      nowPlayingData: widget.nowPlayingData,
                    ),
                  ),
    
                  // Info
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          PlayerInfoWidget(
                            track: currentTrackData,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 16),
                          PlayerProgressBarWidget(
                            position: position,
                            duration: duration,
                            onSeek: (pos) => context.read<PlayerBlocBloc>().add(SeekEvent(pos)),
                          ),
                          const SizedBox(height: 16),
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
    
                  // Similar songs
                  if (!hasError && !isLoading)
                    SliverToBoxAdapter(
                      child: PlayerSimilarSongsWidget(videoId: currentTrackData.videoId),
                    ),
    
                  // Lyrics
                  if (!hasError && !isLoading)
                    SliverToBoxAdapter(
                      child: LyricsWidget(videoId: currentTrackData.videoId),
                    ),
    
                  // Error
                  if (hasError)
                    SliverToBoxAdapter(
                      child: PlayerErrorWidget(message: errorMessage ?? 'Unknown error'),
                    ),
    
                  // Loading
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
        );
  }
}

/// Carrusel de canciones con sincronización automática por videoId
class _PlayerCarousel extends StatefulWidget {
  final List<NowPlayingData> playlist;
  final int currentIndex;
  final NowPlayingData nowPlayingData;

  const _PlayerCarousel({
    required this.playlist,
    required this.currentIndex,
    required this.nowPlayingData,
  });

  @override
  State<_PlayerCarousel> createState() => _PlayerCarouselState();
}

class _PlayerCarouselState extends State<_PlayerCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: _currentIndex,
    );
  }

  int _findIndexByVideoId(String videoId) {
    for (int i = 0; i < widget.playlist.length; i++) {
      if (widget.playlist[i].videoId == videoId) {
        return i;
      }
    }
    return -1;
  }

  void _animateToPage(int page) {
    if (_pageController.hasClients && page >= 0 && page < widget.playlist.length) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay playlist, mostrar artwork normal
    if (widget.playlist.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: PlayerArtworkWidget(
          thumbnail: widget.nowPlayingData.highResThumbnail,
          videoId: widget.nowPlayingData.videoId,
          isLoading: false,
        ),
      );
    }

    // Usar BlocListener para escuchar cambios del PlayerBloc
    return BlocListener<PlayerBlocBloc, PlayerBlocState>(
      listenWhen: (previous, current) {
        // Escuchar cuando cambia el currentTrack
        if (previous is PlayerBlocLoaded && current is PlayerBlocLoaded) {
          return previous.currentTrack?.videoId != current.currentTrack?.videoId ||
                 previous.currentIndex != current.currentIndex;
        }
        return current is PlayerBlocLoaded;
      },
      listener: (context, state) {
        if (state is PlayerBlocLoaded && state.currentTrack != null) {
          final newIndex = _findIndexByVideoId(state.currentTrack!.videoId);
          if (newIndex >= 0 && newIndex != _currentIndex) {
            _currentIndex = newIndex;
            _animateToPage(newIndex);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              _currentIndex = index;
              context.read<PlayerBlocBloc>().add(PlayTrackAtIndexEvent(index));
            },
            itemCount: widget.playlist.length,
            itemBuilder: (context, index) {
              final track = widget.playlist[index];
              return Center(
                child: PlayerArtworkWidget(
                  thumbnail: track.highResThumbnail,
                  videoId: track.videoId,
                  isLoading: false,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
