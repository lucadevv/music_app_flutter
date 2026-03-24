import 'package:flutter/material.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';

class UserPlaylistDetailLoadingOrganism extends StatelessWidget {
  const UserPlaylistDetailLoadingOrganism({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Color(0xFF0D0D0D),
          flexibleSpace: FlexibleSpaceBar(
            background: ThumbnailShimmer(width: double.infinity, height: 300),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(children: [ButtonShimmer(width: 120, height: 48)]),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const SongListItemShimmer(),
            childCount: 10,
          ),
        ),
      ],
    );
  }
}
