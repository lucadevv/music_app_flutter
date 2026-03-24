import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/library/library_service.dart';

/// Molecule: Playlist tile for playlist selection
class PlaylistTileMolecule extends StatelessWidget {
  final UserPlaylist playlist;
  final VoidCallback onTap;

  const PlaylistTileMolecule({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColorsDark.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: playlist.thumbnail != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: playlist.thumbnail!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.queue_music,
                    color: AppColorsDark.primary,
                  ),
                ),
              )
            : const Icon(Icons.queue_music, color: AppColorsDark.primary),
      ),
      title: Text(
        playlist.name,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.songCount} canciones',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
      ),
      onTap: onTap,
    );
  }
}
