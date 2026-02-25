import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/search/domain/entities/thumbnail.dart';

/// Widget para mostrar el artwork del álbum con Hero animation
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar el artwork del álbum
class PlayerArtworkWidget extends StatelessWidget {
  final Thumbnail? thumbnail;
  final String videoId;
  final bool isLoading;
  final bool isBuffering;

  const PlayerArtworkWidget({
    super.key,
    required this.thumbnail,
    required this.videoId,
    this.isLoading = false,
    this.isBuffering = false,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'song_artwork_$videoId',
      child: Stack(
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AppColorsDark.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: thumbnail!.url,
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _PlaceholderWidget(),
                      errorWidget: (context, url, error) => _ErrorWidget(),
                    )
                  : _ErrorWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorsDark.primaryContainer,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColorsDark.primary),
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorsDark.primaryContainer,
      child: Icon(Icons.music_note, size: 120, color: AppColorsDark.primary),
    );
  }
}
