// ignore_for_file: deprecated_member_use_from_same_package
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/presentation/widgets/molecules/molecules.dart';

/// Organismo: SliverAppBar del álbum
class AlbumAppBar extends StatelessWidget {
  final Album album;
  final VoidCallback? onBackPressed;

  const AlbumAppBar({required this.album, super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColorsDark.onSurface,
        ),
        onPressed: onBackPressed ?? () => context.router.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColorsDark.onSurface),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColorsDark.onSurface),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColorsDark.primaryContainer, Color(0xFF0D0D0D)],
            ),
          ),
          child: AlbumHeader(album: album),
        ),
      ),
    );
  }
}
