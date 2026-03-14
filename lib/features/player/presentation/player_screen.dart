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
  final bool playAsSingle; // Si true, reproduce solo esta canción (limpia la cola)

  const PlayerScreen({
    required this.nowPlayingData,
    this.playAsSingle = false,
    super.key,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _hasProcessedNavigation = false;

  // Getter para acceder a nowPlayingData desde widget
  NowPlayingData get _nowPlayingData => widget.nowPlayingData;

  void _handleNavigation(BuildContext context, PlayerBlocState state) {
    final playerBloc = context.read<PlayerBlocBloc>();
    final currentVideoId = state.currentTrack?.videoId;
    final targetVideoId = _nowPlayingData.videoId;

    // Si ya está reproduciendo esta canción, no hacer nada
    if (currentVideoId == targetVideoId) {
      return;
    }

    // Si playAsSingle es true, siempre limpiar la cola y reproducir solo esta canción
    if (widget.playAsSingle) {
      playerBloc.add(LoadTrackEvent(_nowPlayingData, sourceId: null));
      return;
    }

    // Verificar si la canción está en la playlist actual
    if (state.playlist.isNotEmpty) {
      final trackIndex = state.playlist.indexWhere(
        (t) => t.videoId == targetVideoId,
      );

      if (trackIndex >= 0) {
        // Está en la playlist - cambiar al index
        playerBloc.add(PlayTrackAtIndexEvent(trackIndex));
        return;
      }
    }

    // NO está en la playlist - reproducir como canción individual (limpia la cola)
    playerBloc.add(LoadTrackEvent(_nowPlayingData, sourceId: null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        right: false,
        left: false,
        child: BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
          builder: (context, state) {
            // Procesar navegación solo una vez cuando el player está listo
            if (!_hasProcessedNavigation && state.connectionState == AudioConnectionState.connected) {
              _hasProcessedNavigation = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleNavigation(context, state);
              });
            }
            
            final isLoaded = state.connectionState == AudioConnectionState.connected || state.connectionState == AudioConnectionState.connecting;
            
            final playlist = isLoaded ? state.playlist : <NowPlayingData>[];
            final currentIndex = isLoaded ? state.currentIndex : null;
            final currentTrack = isLoaded 
                ? (state.currentTrack ?? _nowPlayingData)
                : _nowPlayingData;
            
            final isLoading = isLoaded && state.isLoading; final isBuffering = isLoaded && state.isBuffering;
            final hasError = isLoaded && state.hasError;
            final errorMessage = isLoaded ? state.error : null;
            
            final isPlaying = isLoaded ? state.isPlaying : false; final canPlayNext = isLoaded ? state.canPlayNext : false;
            final canPlayPrevious = isLoaded ? state.canPlayPrevious : false;
            final isShuffleEnabled = isLoaded ? state.isShuffleEnabled : false;
            final repeatMode = isLoaded ? state.loopMode : LoopMode.off;
            
            final position = isLoaded ? state.position : Duration.zero;
            final duration = isLoaded ? state.duration : Duration.zero;

            return Stack(
              children: [
                // Backdrop
                PlayerBackdropWidget(thumbnail: currentTrack.highResThumbnail),

                // Contenido
                CustomScrollView(
                  slivers: [
                    // Header
                    const SliverToBoxAdapter(child: PlayerHeaderWidget()),

                    // Carrusel de canciones (solo si hay playlist Y NO es playAsSingle)
                    if (playlist.length > 1 && !widget.playAsSingle)
                      SliverToBoxAdapter(
                        child: _SongCarousel(
                          playlist: playlist,
                          currentIndex: currentIndex ?? 0,
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Center(
                            child: PlayerArtworkWidget(
                              thumbnail: currentTrack.highResThumbnail,
                              videoId: currentTrack.videoId,
                              isLoading: isLoading,
                            ),
                          ),
                        ),
                      ),
                         

                    // Info, Progress y Controls
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            PlayerInfoWidget(track: currentTrack, isLoading: isLoading),
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
                              onShuffle: playlist.length > 1 
                                  ? () => context.read<PlayerBlocBloc>().add(const ToggleShuffleEvent())
                                  : null,
                              onRepeat: () {
                                // Cycle: off -> one -> all -> off
                                final currentMode = repeatMode;
                                LoopMode nextMode;
                                if (currentMode == LoopMode.off) {
                                  nextMode = LoopMode.one;
                                } else if (currentMode == LoopMode.one) {
                                  nextMode = LoopMode.all;
                                } else {
                                  nextMode = LoopMode.off;
                                }
                                context.read<PlayerBlocBloc>().add(SetLoopModeEvent(nextMode));
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Similar songs
                    if (!hasError && !isLoading)
                      SliverToBoxAdapter(
                        child: PlayerSimilarSongsWidget(videoId: currentTrack.videoId),
                      ),

                    // Lyrics
                    if (!hasError && !isLoading)
                      SliverToBoxAdapter(
                        child: LyricsWidget(videoId: currentTrack.videoId),
                      ),

                    // Error
                    if (hasError)
                      SliverToBoxAdapter(
                        child: PlayerErrorWidget(message: errorMessage ?? 'Unknown error'),
                      ),

                    // Loading
                    if (isLoading || isBuffering)
                      const SliverToBoxAdapter(child: PlayerShimmerWidget()),

                    // Bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

/// Carrusel de canciones - muy simple
class _SongCarousel extends StatefulWidget {
  final List<NowPlayingData> playlist;
  final int currentIndex;

  const _SongCarousel({
    required this.playlist,
    required this.currentIndex,
  });

  @override
  State<_SongCarousel> createState() => _SongCarouselState();
}

class _SongCarouselState extends State<_SongCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: widget.currentIndex,
    );
  }

  @override
  void didUpdateWidget(_SongCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si cambió el índice significativamente (más de 2 posiciones), hacer scroll
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToIndex(widget.currentIndex);
    }
  }

  void _scrollToIndex(int index) {
    if (!_pageController.hasClients) return;
    if (index < 0 || index >= widget.playlist.length) return;
    
    // Usar jumpToPage que funciona para páginas no cargadas aún
    // Esto es necesario porque PageView.builder carga lazy
    try {
      _pageController.jumpToPage(index);
    } catch (_) {
      // Si jumpToPage falla (página no construida), intentar con animateTo
      // Calcular la posición aproximada
      final viewportWidth = _pageController.position.viewportDimension;
      final itemWidth = viewportWidth * 0.8;
      final targetPosition = index * itemWidth;
      
      try {
        _pageController.jumpTo(targetPosition);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          context.read<PlayerBlocBloc>().add(PlayTrackAtIndexEvent(index));
        },
        itemCount: widget.playlist.length,
        // Usar physics para permitir scroll a páginas no construidas
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final track = widget.playlist[index];
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(right:12),
              child: PlayerArtworkWidget(
                thumbnail: track.highResThumbnail,
                videoId: track.videoId,
                isLoading: false,
              ),
            ),
          );
        },
      ),
    );
  }
}
