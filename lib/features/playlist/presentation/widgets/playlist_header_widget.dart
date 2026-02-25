import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/playlist/presentation/widgets/playlist_backdrop_widget.dart';
import 'package:music_app/features/search/domain/entities/thumbnail.dart';
import '../../domain/entities/playlist_response.dart';

/// Widget para el header de la playlist
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar el header de la playlist
class PlaylistHeaderWidget extends StatelessWidget {
  final PlaylistResponse playlist;

  const PlaylistHeaderWidget({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    // Obtener la mejor thumbnail
    Thumbnail? bestThumbnail;
    if (playlist.thumbnails.isNotEmpty) {
      bestThumbnail = playlist.thumbnails.first;
      for (final thumbnail in playlist.thumbnails) {
        if (thumbnail.width > bestThumbnail!.width) {
          bestThumbnail = thumbnail;
        }
      }
    }

    return Stack(
      children: [
        PlaylistBackdropWidget(thumbnail: bestThumbnail),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen de la playlist centrada
                if (bestThumbnail != null)
                  Hero(
                    tag: 'playlist_${playlist.id}',
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: bestThumbnail.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColorsDark.primaryContainer,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColorsDark.primaryContainer,
                            child: const Icon(
                              Icons.playlist_play,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColorsDark.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.playlist_play,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(height: 20),
                // Título centrado
                Text(
                  playlist.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Metadata centrada
                Text(
                  '${playlist.author.name} • ${playlist.trackCount} songs • ${playlist.duration}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
