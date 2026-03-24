import 'package:flutter/material.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';

/// Molécula: DownloadsLoadingView
///
/// Muestra un skeleton de loading para la lista de descargas.
class DownloadsLoadingView extends StatelessWidget {
  final int itemCount;

  const DownloadsLoadingView({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              // Avatar
              ShimmerContainer(width: 48, height: 48, borderRadius: 8),
              SizedBox(width: 16),
              // Titles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextShimmer(width: double.infinity, height: 14),
                    SizedBox(height: 4),
                    TextShimmer(width: 100, height: 12),
                  ],
                ),
              ),
              SizedBox(width: 16),
              // Options / Remove button
              ShimmerContainer(width: 24, height: 24, borderRadius: 12),
            ],
          ),
        );
      },
    );
  }
}
