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

  const HomeSectionWidget({
    super.key,
    required this.section,
    required this.onSongTap,
    this.onPlaylistTap,
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
    // Si todos los items son canciones, mostrar lista horizontal
    if (section.contents.every((item) => item.isSong)) {
      return SizedBox(
        height: 140,
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

    // Si todos los items son playlists, mostrar lista horizontal
    if (section.contents.every((item) => item.isPlaylist)) {
      return SizedBox(
        height: 140,
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

    // Lista vertical mixta
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: section.contents.length,
      itemBuilder: (context, index) {
        final item = section.contents[index];
        if (item.isSong) {
          return SongListItemWidget(
            item: item,
            onTap: () => onSongTap(item),
          );
        } else if (item.isPlaylist) {
          return PlaylistListItemWidget(
            item: item,
            onTap: () => onPlaylistTap?.call(item),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
