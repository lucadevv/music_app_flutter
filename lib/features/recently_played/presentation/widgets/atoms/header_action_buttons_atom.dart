import 'package:flutter/material.dart';

class SearchButtonAtom extends StatelessWidget {
  final VoidCallback onPressed;

  const SearchButtonAtom({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search, color: Colors.white),
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
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onPressed: onPressed,
    );
  }
}
