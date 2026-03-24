import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/presentation/widgets/molecules/player_artwork_widget.dart';

class PlayerPlaylistCarouselWidget extends StatefulWidget {
  final List<NowPlayingData> playlist;
  final int currentIndex;

  const PlayerPlaylistCarouselWidget({
    required this.playlist,
    required this.currentIndex,
    super.key,
  });

  @override
  State<PlayerPlaylistCarouselWidget> createState() =>
      _PlayerPlaylistCarouselWidgetState();
}

class _PlayerPlaylistCarouselWidgetState
    extends State<PlayerPlaylistCarouselWidget> {
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
  void didUpdateWidget(PlayerPlaylistCarouselWidget oldWidget) {
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
