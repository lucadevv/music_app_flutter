import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/presentation/widgets/molecules/player_artwork_widget.dart';

/// Widget de carrusel estilo Tinder con cartas deslizables
class SwipeableSongCardsWidget extends StatefulWidget {
  final List<NowPlayingData> playlist;
  final int currentIndex;
  final Function(int) onCardSwiped;

  const SwipeableSongCardsWidget({
    required this.playlist,
    required this.currentIndex,
    required this.onCardSwiped,
    super.key,
  });

  @override
  State<SwipeableSongCardsWidget> createState() => _SwipeableSongCardsWidgetState();
}

class _SwipeableSongCardsWidgetState extends State<SwipeableSongCardsWidget> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.currentIndex,
      viewportFraction: 0.85,
    );
  }

  @override
  void didUpdateWidget(SwipeableSongCardsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _pageController.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
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
    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: widget.onCardSwiped,
        itemCount: widget.playlist.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final track = widget.playlist[index];
          final isCurrentCard = index == widget.currentIndex;
          final scale = isCurrentCard ? 1.0 : 0.9;
          final opacity = isCurrentCard ? 1.0 : 0.7;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: _buildCard(track, index, isCurrentCard),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(NowPlayingData track, int index, bool isCurrentCard) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isCurrentCard ? 0.5 : 0.3),
            blurRadius: isCurrentCard ? 20 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Artwork
            PlayerArtworkWidget(
              thumbnail: track.highResThumbnail,
              videoId: track.videoId,
              isLoading: false,
            ),
            // Overlay gradiente
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
            // Info de la canción
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artistsNames,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Indicador de canción actual
            if (isCurrentCard)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColorsDark.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${index + 1}/${widget.playlist.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
