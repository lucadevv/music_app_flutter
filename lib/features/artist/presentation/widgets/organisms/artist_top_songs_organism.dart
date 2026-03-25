import 'package:flutter/material.dart';
import 'package:music_app/core/domain/entities/artist.dart';
import 'package:music_app/features/artist/presentation/widgets/molecules/artist_song_item_molecule.dart';
import 'package:music_app/l10n/app_localizations.dart';

class ArtistTopSongsOrganism extends StatelessWidget {
  final List<ArtistSong> songs;
  final void Function(ArtistSong song, List<ArtistSong> allSongs) onSongTap;

  const ArtistTopSongsOrganism({
    required this.songs, required this.onSongTap, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (songs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.popular),
        const SizedBox(height: 16),
        _buildSongsList(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSongsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final song = songs[index];
        return ArtistSongItemMolecule(
          song: song,
          index: index + 1,
          onTap: () => onSongTap(song, songs),
        );
      }, childCount: songs.length),
    );
  }
}
