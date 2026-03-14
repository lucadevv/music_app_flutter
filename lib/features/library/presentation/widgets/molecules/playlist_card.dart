import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistItem playlist;
  final VoidCallback onTap;

  const PlaylistCard({required this.playlist, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
               borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 150,
                width: 150,
                color: AppColorsDark.primaryContainer,
                child: playlist.thumbnail != null
                   ? CachedNetworkImage(
                        imageUrl: playlist.thumbnail!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _buildPlaceholder(),
                        errorWidget: (_, _, _) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              playlist.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (playlist.songCount > 0)
              Text(
                '${playlist.songCount} songs',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Icon(
      Icons.playlist_play,
      size: 48,
      color: AppColorsDark.primary,
    );
  }
}
