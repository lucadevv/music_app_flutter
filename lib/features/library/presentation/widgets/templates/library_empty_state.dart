import 'package:flutter/material.dart';

class LibraryEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onExplore;

  const LibraryEmptyState({
    required this.message,
    required this.onExplore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_music_outlined, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onExplore, child: const Text('Explore')),
        ],
      ),
    );
  }
}
