import 'package:flutter/material.dart';
import '../atoms/grid_image.dart';

class ImageColumn extends StatelessWidget {
  final List<ImageColumnItem> items;
  final double? topSpacing;

  const ImageColumn({super.key, required this.items, this.topSpacing});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topSpacing != null) SizedBox(height: topSpacing),
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          GridImage(url: items[i].url, height: items[i].height),
        ],
      ],
    );
  }
}

class ImageColumnItem {
  final String url;
  final double height;

  const ImageColumnItem({required this.url, required this.height});
}
