import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/features/playlist/presentation/widgets/molecules/playlist_app_bar_actions.dart';
import 'package:music_app/features/playlist/presentation/widgets/organisms/playlist_header_widget.dart';

class PlaylistSliverAppBar extends StatelessWidget {
  final dynamic playlist;
  final bool showSearch;
  final VoidCallback onSearchPressed;
  final VoidCallback onMorePressed;

  const PlaylistSliverAppBar({
    required this.playlist, required this.showSearch, required this.onSearchPressed, required this.onMorePressed, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildBackButton(context),
      actions: [
        PlaylistAppBarActions(
          showSearch: showSearch,
          onSearchPressed: onSearchPressed,
          onMorePressed: onMorePressed,
        ),
      ],
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(
              left: 16,
              bottom: 16,
              right: 16,
            ),
            background: PlaylistHeaderWidget(playlist: playlist),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => context.router.pop(),
      ),
    );
  }
}
