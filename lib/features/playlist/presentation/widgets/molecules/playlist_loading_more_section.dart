import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_state.dart';
import 'package:music_app/features/playlist/presentation/widgets/molecules/playlist_load_more_button.dart';

class PlaylistLoadingMoreSection extends StatelessWidget {
  final PlaylistStatus status;
  final bool hasMore;
  final int loadedCount;
  final int totalCount;
  final VoidCallback onLoadMore;

  const PlaylistLoadingMoreSection({
    required this.status,
    required this.hasMore,
    required this.loadedCount,
    required this.totalCount,
    required this.onLoadMore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (status == PlaylistStatus.loadingMore) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColorsDark.onSurface54,
              ),
            ),
          ),
        ),
      );
    }

    if (hasMore) {
      return PlaylistLoadMoreButton(
        loadedCount: loadedCount,
        totalCount: totalCount,
        onPressed: onLoadMore,
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
