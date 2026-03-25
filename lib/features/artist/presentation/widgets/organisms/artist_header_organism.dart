import 'package:flutter/material.dart';
import 'package:music_app/core/domain/entities/artist.dart';
import 'package:music_app/features/artist/presentation/cubit/artist_cubit.dart';
import 'package:music_app/features/artist/presentation/widgets/atoms/artist_backdrop_widget.dart';
import 'package:music_app/features/artist/presentation/widgets/molecules/artist_action_buttons.dart';

class ArtistHeaderOrganism extends StatelessWidget {
  final Artist artist;
  final ArtistState state;
  final VoidCallback onBackPressed;

  const ArtistHeaderOrganism({
    required this.artist, required this.state, required this.onBackPressed, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: onBackPressed,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            ArtistBackdropWidget(thumbnail: artist.thumbnail),
            _buildGradientOverlay(),
            _buildArtistInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
        ),
      ),
    );
  }

  Widget _buildArtistInfo() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            artist.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (artist.monthlyListeners != null)
            Text(
              _formatListeners(artist.monthlyListeners!),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  String _formatListeners(int listeners) {
    if (listeners >= 1000000) {
      return '${(listeners / 1000000).toStringAsFixed(1)}M monthly listeners';
    } else if (listeners >= 1000) {
      return '${(listeners / 1000).toStringAsFixed(1)}K monthly listeners';
    }
    return '$listeners monthly listeners';
  }
}

class ArtistContentWithActions extends StatelessWidget {
  final Artist artist;
  final ArtistState state;
  final VoidCallback onPlayPressed;
  final VoidCallback onFollowPressed;
  final List<Widget> children;

  const ArtistContentWithActions({
    required this.artist, required this.state, required this.onPlayPressed, required this.onFollowPressed, required this.children, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtistActionButtons(
            artist: artist,
            state: state,
            onPlayPressed: onPlayPressed,
            onFollowPressed: onFollowPressed,
          ),
          const SizedBox(height: 32),
          ...children,
        ],
      ),
    );
  }
}
