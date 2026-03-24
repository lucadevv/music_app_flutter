import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';

class ArtistAlbumCardMolecule extends StatelessWidget {
  final ArtistAlbum album;
  final VoidCallback onTap;

  const ArtistAlbumCardMolecule({
    super.key,
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlbumImage(),
            const SizedBox(height: 8),
            _buildAlbumTitle(),
            const SizedBox(height: 2),
            _buildAlbumSubtitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 130,
        width: 140,
        color: AppColorsDark.primaryContainer,
        child: album.thumbnail != null
            ? CachedNetworkImage(
                imageUrl: album.thumbnail!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _buildDefaultIcon(),
              )
            : _buildDefaultIcon(),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return const Icon(Icons.album, size: 48, color: AppColorsDark.primary);
  }

  Widget _buildAlbumTitle() {
    return Text(
      album.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAlbumSubtitle() {
    return Text(
      '${album.year} • ${album.songCount} songs',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 11,
      ),
    );
  }
}
