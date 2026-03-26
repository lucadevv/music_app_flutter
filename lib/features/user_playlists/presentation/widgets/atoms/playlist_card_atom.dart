import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class PlaylistCardAtom extends StatelessWidget {
  final String name;
  final String? thumbnail;
  final int songCount;
  final VoidCallback onTap;

  const PlaylistCardAtom({
    required this.name,
    required this.songCount,
    required this.onTap,
    this.thumbnail,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: thumbnail!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: AppColorsDark.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(
                          Icons.playlist_play,
                          size: 48,
                          color: AppColorsDark.onSurface24,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: AppColorsDark.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$songCount songs',
            style: const TextStyle(
              color: AppColorsDark.onSurface54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
