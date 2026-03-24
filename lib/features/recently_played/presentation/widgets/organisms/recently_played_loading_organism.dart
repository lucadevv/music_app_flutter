import 'package:flutter/material.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';

class RecentlyPlayedLoadingOrganism extends StatelessWidget {
  final int itemCount;

  const RecentlyPlayedLoadingOrganism({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const SongListItemShimmer(),
        childCount: itemCount,
      ),
    );
  }
}
