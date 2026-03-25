import 'package:flutter/material.dart';
import 'package:music_app/features/song_options/presentation/widgets/atoms/text_atoms.dart';
import 'package:music_app/features/song_options/presentation/widgets/atoms/thumbnail_atom.dart';

/// Molecule: Song header with thumbnail, title, and artist
class SongHeaderMolecule extends StatelessWidget {
  final String title;
  final String artist;
  final String? thumbnail;

  const SongHeaderMolecule({
    required this.title, required this.artist, super.key,
    this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ThumbnailAtom(thumbnailUrl: thumbnail),
      title: SongTitleAtom(title: title),
      subtitle: ArtistTextAtom(artist: artist),
    );
  }
}
