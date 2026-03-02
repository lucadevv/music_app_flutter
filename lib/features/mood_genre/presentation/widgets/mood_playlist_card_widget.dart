import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import '../../domain/entities/mood_playlist.dart';

/// Widget para mostrar una playlist de mood/genre en formato card
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar una card de playlist
class MoodPlaylistCardWidget extends StatelessWidget {
  final MoodPlaylist playlist;
  final VoidCallback onTap;

  const MoodPlaylistCardWidget({
    required this.playlist,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = playlist.thumbnails.isNotEmpty
        ? playlist.thumbnails.last
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColorsDark.primaryContainer,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: thumbnail != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: thumbnail.url,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColorsDark.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.playlist_play,
                            size: 60,
                            color: AppColorsDark.primary,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.playlist_play,
                          size: 60,
                          color: AppColorsDark.primary,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (playlist.author.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      playlist.author,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (playlist.itemCount.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${playlist.itemCount} canciones',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
