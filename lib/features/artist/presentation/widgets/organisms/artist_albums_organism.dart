import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/artist/presentation/widgets/molecules/artist_album_card_molecule.dart';

class ArtistAlbumsOrganism extends StatelessWidget {
  final List<ArtistAlbum> albums;
  final StackRouter router;

  const ArtistAlbumsOrganism({
    super.key,
    required this.albums,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(),
          const SizedBox(height: 16),
          _buildAlbumsRow(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Text(
        'Albums',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAlbumsRow() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return ArtistAlbumCardMolecule(
            album: album,
            onTap: () => router.push(AlbumRoute(albumId: album.id)),
          );
        },
      ),
    );
  }
}
