import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class ArtistNotFoundWidget extends StatelessWidget {
  const ArtistNotFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Artista no encontrado',
        style: TextStyle(color: AppColorsDark.onSurface.withValues(alpha: 0.7)),
      ),
    );
  }
}
