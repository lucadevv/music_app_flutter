import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/presentation/widgets/atoms/player_backdrop_widget.dart';
import 'package:music_app/features/player/presentation/widgets/atoms/player_error_widget.dart';
import 'package:music_app/features/player/presentation/widgets/molecules/player_artwork_widget.dart';
import 'package:music_app/features/player/presentation/widgets/molecules/player_controls_widget.dart';
import 'package:music_app/features/player/presentation/widgets/molecules/player_header_widget.dart';
import 'package:music_app/features/player/presentation/widgets/molecules/player_info_widget.dart';
import 'package:music_app/features/player/presentation/widgets/molecules/player_progress_bar_widget.dart';
import 'package:music_app/features/player/presentation/widgets/organisms/lyrics_widget.dart';
import 'package:music_app/features/player/presentation/widgets/organisms/player_shimmer_widgets.dart';
import 'package:music_app/features/player/presentation/widgets/organisms/player_similar_songs_widget.dart';

@RoutePage()
class PlayerScreen extends StatefulWidget {
  final NowPlayingData nowPlayingData;
  final bool playAsSingle;
  final bool showFavoriteButton;
  final bool showExtras;

  const PlayerScreen({
    required this.nowPlayingData,
    this.playAsSingle = false,
    this.showFavoriteButton = true,
    this.showExtras = true,
    super.key,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _hasRequestedPlay = false;
  String? _lastVideoId;

  NowPlayingData get _nowPlayingData => widget.nowPlayingData;

  @override
  void initState() {
    super.initState();
    _lastVideoId = _nowPlayingData.videoId;
  }

  @override
  void didUpdateWidget(PlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nowPlayingData.videoId != widget.nowPlayingData.videoId) {
      _hasRequestedPlay = false;
      _lastVideoId = widget.nowPlayingData.videoId;
    }
  }

  void _requestPlayIfNeeded(PlayerBlocBloc bloc, PlayerBlocState state) {
    if (_hasRequestedPlay) return;
    if (_nowPlayingData.videoId != _lastVideoId) return;

    final hasValidUrl =
        _nowPlayingData.streamUrl != null &&
        _nowPlayingData.streamUrl!.isNotEmpty;
    if (!hasValidUrl) return;

    final isCurrentSong =
        state.currentTrack?.videoId == _nowPlayingData.videoId;
    final isAlreadyPlaying = isCurrentSong && state.isPlaying;

    if (isAlreadyPlaying) return;

    _hasRequestedPlay = true;

    if (widget.playAsSingle) {
      bloc.add(
        LoadTrackEvent(
          _nowPlayingData,
          sourceId: 'single:${_nowPlayingData.videoId}',
        ),
      );
    } else {
      bloc.add(PlayRequestEvent(_nowPlayingData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        right: false,
        left: false,
        child: BlocConsumer<PlayerBlocBloc, PlayerBlocState>(
          listener: (context, state) {
            // Cuando el estado cambia, verificar si necesitamos iniciar reproducción
            _requestPlayIfNeeded(context.read<PlayerBlocBloc>(), state);
          },
          builder: (context, state) {
            final isLoaded =
                state.connectionState == AudioConnectionState.connected ||
                state.connectionState == AudioConnectionState.connecting;

            final isCurrentSong =
                state.currentTrack?.videoId == _nowPlayingData.videoId;

            final currentTrack = (isCurrentSong && state.currentTrack != null)
                ? state.currentTrack!
                : _nowPlayingData;

            final playlist = state.playlist;
            final currentIndex = state.currentIndex;

            final isLoading = isLoaded && state.isLoading;
            final isBuffering = isLoaded && state.isBuffering;
            final hasError = isLoaded && state.hasError;
            final errorMessage = state.error;

            final isPlaying = isLoaded && state.isPlaying;
            final canPlayNext = isLoaded && state.canPlayNext;
            final canPlayPrevious = isLoaded && state.canPlayPrevious;
            final isShuffleEnabled = isLoaded && state.isShuffleEnabled;
            final repeatMode = isLoaded ? state.loopMode : LoopMode.off;

            final position = state.position;
            final duration = state.duration.inMilliseconds > 0
                ? state.duration
                : Duration(seconds: currentTrack.durationSeconds);

            return Stack(
              children: [
                PlayerBackdropWidget(thumbnail: currentTrack.highResThumbnail),

                CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: PlayerHeaderWidget()),

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

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            PlayerInfoWidget(
                              track: currentTrack,
                              isLoading: isLoading,
                              showFavoriteButton: widget.showFavoriteButton,
                            ),
                            const SizedBox(height: 16),
                            PlayerProgressBarWidget(
                              position: position,
                              duration: duration,
                              onSeek: (pos) => context
                                  .read<PlayerBlocBloc>()
                                  .add(SeekEvent(pos)),
                            ),
                            const SizedBox(height: 16),
                            PlayerControlsWidget(
                              isPlaying: isPlaying,
                              canPlayNext: canPlayNext,
                              canPlayPrevious: canPlayPrevious,
                              isShuffleEnabled: isShuffleEnabled,
                              loopMode: repeatMode,
                              onPlayPause: () => context
                                  .read<PlayerBlocBloc>()
                                  .add(const PlayPauseToggleEvent()),
                              onNext: () => context.read<PlayerBlocBloc>().add(
                                const NextTrackEvent(),
                              ),
                              onPrevious: () => context
                                  .read<PlayerBlocBloc>()
                                  .add(const PreviousTrackEvent()),
                              onShuffle: playlist.length > 1
                                  ? () => context.read<PlayerBlocBloc>().add(
                                      const ToggleShuffleEvent(),
                                    )
                                  : null,
                              onRepeat: () {
                                final currentMode = repeatMode;
                                LoopMode nextMode;
                                if (currentMode == LoopMode.off) {
                                  nextMode = LoopMode.one;
                                } else if (currentMode == LoopMode.one) {
                                  nextMode = LoopMode.all;
                                } else {
                                  nextMode = LoopMode.off;
                                }
                                context.read<PlayerBlocBloc>().add(
                                  SetLoopModeEvent(nextMode),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    if (widget.showExtras && !hasError && !isLoading)
                      SliverToBoxAdapter(
                        child: PlayerSimilarSongsWidget(
                          videoId: currentTrack.videoId,
                        ),
                      ),

                    if (widget.showExtras && !hasError && !isLoading)
                      SliverToBoxAdapter(
                        child: LyricsWidget(videoId: currentTrack.videoId),
                      ),

                    if (hasError)
                      SliverToBoxAdapter(
                        child: PlayerErrorWidget(
                          message: errorMessage ?? 'Unknown error',
                        ),
                      ),

                    if (isLoading || isBuffering)
                      const SliverToBoxAdapter(child: PlayerShimmerWidget()),

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

class _SongCarousel extends StatefulWidget {
  final List<NowPlayingData> playlist;
  final int currentIndex;

  const _SongCarousel({required this.playlist, required this.currentIndex});

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
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToIndex(widget.currentIndex);
    }
  }

  void _scrollToIndex(int index) {
    if (!_pageController.hasClients) return;
    if (index < 0 || index >= widget.playlist.length) return;

    try {
      _pageController.jumpToPage(index);
    } catch (_) {
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
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final track = widget.playlist[index];
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
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
