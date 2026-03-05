import 'package:flutter/material.dart';
import 'package:music_app/features/home/domain/entities/home_content_item.dart';
import 'package:music_app/features/home/domain/entities/home_section.dart';
import 'home_content_widgets.dart';

/// Widget para mostrar una sección del home
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar una sección con su título y contenido
class HomeSectionWidget extends StatelessWidget {
  final HomeSection section;
  final Function(HomeContentItem) onSongTap;
  final Function(HomeContentItem)? onPlaylistTap;
  final Function(HomeContentItem)? onAlbumTap;

  const HomeSectionWidget({
    super.key,
    required this.section,
    required this.onSongTap,
    this.onPlaylistTap,
    this.onAlbumTap,
  });

  @override
  Widget build(BuildContext context) {
    if (section.contents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(
            section.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Contenido de la sección
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    // Determinar tipo predominante en la sección
    final songs = section.contents.where((item) => item.contentType == HomeContentType.song).toList();
    final albums = section.contents.where((item) => item.contentType == HomeContentType.album).toList();
    final playlists = section.contents.where((item) => item.contentType == HomeContentType.playlist).toList();

    // Si solo hay canciones -> card horizontal
    if (songs.length == section.contents.length) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: section.contents.length,
          itemBuilder: (context, index) {
            final item = section.contents[index];
            return SongCardWidget(
              item: item,
              onTap: () => onSongTap(item),
            );
          },
        ),
      );
    }

    // Si solo hay álbumes -> card horizontal
    if (albums.length == section.contents.length) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: section.contents.length,
          itemBuilder: (context, index) {
            final item = section.contents[index];
            return AlbumCardWidget(
              item: item,
              onTap: () => onAlbumTap?.call(item),
            );
          },
        ),
      );
    }

    // Si solo hay playlists -> card horizontal
    if (playlists.length == section.contents.length) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: section.contents.length,
          itemBuilder: (context, index) {
            final item = section.contents[index];
            return PlaylistCardWidget(
              item: item,
              onTap: () => onPlaylistTap?.call(item),
            );
          },
        ),
      );
    }

    // Lista vertical mixta (Songs, Albums, Playlists)
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: section.contents.length,
      itemBuilder: (context, index) {
        final item = section.contents[index];
        
        switch (item.contentType) {
          case HomeContentType.song:
            return SongListItemWidget(
              item: item,
              onTap: () => onSongTap(item),
            );
          case HomeContentType.album:
            return AlbumListItemWidget(
              item: item,
              onTap: () => onAlbumTap?.call(item),
            );
          case HomeContentType.playlist:
            return PlaylistListItemWidget(
              item: item,
              onTap: () => onPlaylistTap?.call(item),
            );
          case HomeContentType.unknown:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
