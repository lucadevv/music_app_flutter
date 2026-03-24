import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';
import 'package:music_app/features/artist/presentation/widgets/atoms/artist_backdrop_widget.dart';
import 'package:music_app/features/artist/presentation/widgets/atoms/artist_shimmer_atoms.dart';

class ArtistLoadingMolecule extends StatelessWidget {
  const ArtistLoadingMolecule({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        const ArtistLoadingButtonsAtom(),
        const ArtistLoadingTitleShimmer(width: 100),
        _buildSongsList(),
        const ArtistLoadingTitleShimmer(width: 80),
        _buildAlbumsRow(),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () {},
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            const ArtistBackdropWidget(thumbnail: null),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColorsDark.primaryContainer.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const Center(child: AvatarShimmer(size: 150)),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const SongListItemShimmer(),
        childCount: 5,
      ),
    );
  }

  Widget _buildAlbumsRow() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          itemBuilder: (context, index) => const ArtistLoadingAlbumShimmer(),
        ),
      ),
    );
  }
}
