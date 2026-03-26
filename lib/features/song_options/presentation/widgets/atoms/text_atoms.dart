import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Atom: Song title text with styling
class SongTitleAtom extends StatelessWidget {
  final String title;
  final int maxLines;

  const SongTitleAtom({required this.title, super.key, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColorsDark.onSurface,
        fontWeight: FontWeight.w600,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Atom: Artist/subtitle text with styling
class ArtistTextAtom extends StatelessWidget {
  final String artist;

  const ArtistTextAtom({required this.artist, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      artist,
      style: TextStyle(color: AppColorsDark.onSurface.withValues(alpha: 0.6)),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
