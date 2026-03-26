import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class SearchButtonAtom extends StatelessWidget {
  final VoidCallback onPressed;

  const SearchButtonAtom({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search, color: AppColorsDark.onSurface),
      onPressed: onPressed,
    );
  }
}

class MoreButtonAtom extends StatelessWidget {
  final VoidCallback onPressed;

  const MoreButtonAtom({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert, color: AppColorsDark.onSurface),
      onPressed: onPressed,
    );
  }
}
