import 'package:flutter/material.dart';

class PlaylistLoadMoreButton extends StatelessWidget {
  final int loadedCount;
  final int totalCount;
  final VoidCallback onPressed;

  const PlaylistLoadMoreButton({
    required this.loadedCount, required this.totalCount, required this.onPressed, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            'Cargar más canciones ($loadedCount/$totalCount)',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
