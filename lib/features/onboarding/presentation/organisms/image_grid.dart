import 'package:flutter/material.dart';
import '../atoms/grid_image.dart';

class OnboardingImageGrid extends StatelessWidget {
  const OnboardingImageGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 550,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 12),
            // Column 1
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GridImage(
                  url:
                      'https://images.unsplash.com/photo-1493225457124-a1a2a5f5f4a4?q=80&w=400&fit=crop',
                  height: 160,
                ),
                const SizedBox(height: 12),
                GridImage(
                  url:
                      'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?q=80&w=400&fit=crop',
                  height: 200,
                ),
                const SizedBox(height: 12),
                GridImage(
                  url:
                      'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=400&fit=crop',
                  height: 150,
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Column 2
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 60),
                GridImage(
                  url:
                      'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?q=80&w=400&fit=crop',
                  height: 200,
                ),
                const SizedBox(height: 12),
                GridImage(
                  url:
                      'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?q=80&w=400&fit=crop',
                  height: 170,
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Column 3
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                GridImage(
                  url:
                      'https://images.unsplash.com/photo-1501612780327-45045538702b?q=80&w=400&fit=crop',
                  height: 170,
                ),
                const SizedBox(height: 12),
                GridImage(
                  url:
                      'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=400&fit=crop',
                  height: 210,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
