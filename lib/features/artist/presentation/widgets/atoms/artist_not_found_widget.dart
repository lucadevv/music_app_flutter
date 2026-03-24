import 'package:flutter/material.dart';

class ArtistNotFoundWidget extends StatelessWidget {
  const ArtistNotFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Artista no encontrado',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }
}
