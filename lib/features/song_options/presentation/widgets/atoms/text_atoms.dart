import 'package:flutter/material.dart';

/// Atom: Song title text with styling
class SongTitleAtom extends StatelessWidget {
  final String title;
  final int maxLines;

  const SongTitleAtom({super.key, required this.title, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Atom: Artist/subtitle text with styling
class ArtistTextAtom extends StatelessWidget {
  final String artist;

  const ArtistTextAtom({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Text(
      artist,
      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
