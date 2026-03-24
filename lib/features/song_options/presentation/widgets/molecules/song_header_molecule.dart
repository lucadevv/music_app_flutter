import 'package:flutter/material.dart';
import 'package:music_app/features/song_options/presentation/widgets/atoms/thumbnail_atom.dart';
import 'package:music_app/features/song_options/presentation/widgets/atoms/text_atoms.dart';

/// Molecule: Song header with thumbnail, title, and artist
class SongHeaderMolecule extends StatelessWidget {
  final String title;
  final String artist;
  final String? thumbnail;

  const SongHeaderMolecule({
    super.key,
    required this.title,
    required this.artist,
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
