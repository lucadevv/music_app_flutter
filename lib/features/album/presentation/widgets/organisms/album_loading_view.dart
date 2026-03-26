import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';
import 'package:music_app/features/album/presentation/widgets/atoms/atoms.dart';

/// Organismo: Vista de loading con shimmer
class AlbumLoadingView extends StatelessWidget {
  const AlbumLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App Bar con shimmer
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColorsDark.onSurface,
            ),
            onPressed: () => context.router.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColorsDark.primaryContainer, Color(0xFF0D0D0D)],
                ),
              ),
              child: const AlbumHeaderShimmer(),
            ),
          ),
        ),

        // Action buttons shimmer
        const SliverToBoxAdapter(child: ActionButtonsShimmer()),

        // Songs list shimmer
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const SongListItemShimmer(),
            childCount: 10,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
