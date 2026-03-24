import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class GridImage extends StatelessWidget {
  final String url;
  final double height;
  final double width;

  const GridImage({
    super.key,
    required this.url,
    required this.height,
    this.width = 110,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColorsDark.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(color: AppColorsDark.surfaceContainerHigh),
          errorWidget: (context, url, error) =>
              const Icon(Icons.music_note, color: Colors.grey),
        ),
      ),
    );
  }
}
