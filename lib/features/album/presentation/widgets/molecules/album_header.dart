import 'package:flutter/material.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/presentation/widgets/atoms/atoms.dart';

/// Molécula: Header del álbum (thumbnail + info)
class AlbumHeader extends StatelessWidget {
  final Album album;

  const AlbumHeader({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlbumThumbnail(thumbnailUrl: album.thumbnail),
          const SizedBox(height: 16),
          AlbumInfoText(
            title: album.title,
            subtitle: '${album.artistName ?? 'Unknown Artist'} • ${album.year}',
          ),
        ],
      ),
    );
  }
}
