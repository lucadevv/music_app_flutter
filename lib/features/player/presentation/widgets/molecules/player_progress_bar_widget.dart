import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:shimmer/shimmer.dart';

/// Widget para la barra de progreso del reproductor
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar y controlar el progreso de reproducción
class PlayerProgressBarWidget extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final void Function(Duration)? onSeek;
  final bool isLoading;

  const PlayerProgressBarWidget({
    required this.position,
    required this.duration,
    super.key,
    this.onSeek,
    this.isLoading = false,
  });

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) return '0:00';

    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: [
          Shimmer.fromColors(
            baseColor: AppColorsDark.onSurface.withValues(alpha: 0.1),
            highlightColor: AppColorsDark.onSurface.withValues(alpha: 0.2),
            child: Container(
              height: 2,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColorsDark.onSurface,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: AppColorsDark.onSurface.withValues(alpha: 0.1),
                  highlightColor: AppColorsDark.onSurface.withValues(
                    alpha: 0.2,
                  ),
                  child: Container(
                    height: 12,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColorsDark.onSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: AppColorsDark.onSurface.withValues(alpha: 0.1),
                  highlightColor: AppColorsDark.onSurface.withValues(
                    alpha: 0.2,
                  ),
                  child: Container(
                    height: 12,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColorsDark.onSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColorsDark.onSurface,
            inactiveTrackColor: AppColorsDark.onSurface.withValues(alpha: 0.3),
            thumbColor: AppColorsDark.onSurface,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 2,
          ),
          child: Slider(
            value: progress,
            min: 0.0,
            max: 1.0,
            onChanged: onSeek != null && duration.inMilliseconds > 0
                ? (value) {
                    final clampedValue = value.clamp(0.0, 1.0);
                    final newPosition = Duration(
                      milliseconds: (clampedValue * duration.inMilliseconds)
                          .round(),
                    );
                    onSeek!(newPosition);
                  }
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(
                  color: AppColorsDark.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(
                  color: AppColorsDark.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
