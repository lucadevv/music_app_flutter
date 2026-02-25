import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widgets de shimmer para el reproductor
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar placeholders de carga con shimmer

class TitleShimmer extends StatelessWidget {
  const TitleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.1),
      highlightColor: Colors.white.withValues(alpha: 0.2),
      child: Container(
        height: 28,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class SubtitleShimmer extends StatelessWidget {
  final double width;

  const SubtitleShimmer({super.key, this.width = 180});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.1),
      highlightColor: Colors.white.withValues(alpha: 0.2),
      child: Container(
        height: 16,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class MetadataShimmer extends StatelessWidget {
  const MetadataShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.1),
      highlightColor: Colors.white.withValues(alpha: 0.2),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class PlaybackControlsShimmer extends StatelessWidget {
  const PlaybackControlsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ShimmerCircle(size: 48),
        const SizedBox(width: 16),
        _ShimmerCircle(size: 48),
        const SizedBox(width: 16),
        _ShimmerCircle(size: 64),
        const SizedBox(width: 16),
        _ShimmerCircle(size: 48),
        const SizedBox(width: 16),
        _ShimmerCircle(size: 48),
      ],
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double size;

  const _ShimmerCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.1),
      highlightColor: Colors.white.withValues(alpha: 0.2),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
