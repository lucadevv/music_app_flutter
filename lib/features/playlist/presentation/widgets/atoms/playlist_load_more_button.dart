import 'package:flutter/material.dart';

class PlaylistLoadMoreButton extends StatelessWidget {
  final int currentCount;
  final int? totalCount;
  final VoidCallback onPressed;

  const PlaylistLoadMoreButton({
    super.key,
    required this.currentCount,
    this.totalCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          'Cargar más canciones ($currentCount/${totalCount?.toString() ?? "?"})',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ),
    );
  }
}
