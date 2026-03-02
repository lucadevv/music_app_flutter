import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Widget para los controles de reproducción
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar y manejar controles de reproducción
class PlayerControlsWidget extends StatelessWidget {
  final bool isPlaying;
  final bool canPlayNext;
  final bool canPlayPrevious;
  final bool isShuffleEnabled;
  final LoopMode loopMode;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onShuffle;
  final VoidCallback? onRepeat;

  const PlayerControlsWidget({
    required this.isPlaying, required this.canPlayNext, required this.canPlayPrevious, required this.isShuffleEnabled, required this.loopMode, super.key,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onShuffle,
    this.onRepeat,
  });

  Color _getRepeatColor() {
    switch (loopMode) {
      case LoopMode.off:
        return Colors.white.withValues(alpha: 0.6);
      case LoopMode.one:
        return AppColorsDark.primary;
      case LoopMode.all:
        return AppColorsDark.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: isShuffleEnabled ? AppColorsDark.primary : Colors.white,
          ),
          onPressed: onShuffle,
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(
            Icons.skip_previous,
            color: canPlayPrevious
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            size: 32,
          ),
          onPressed: canPlayPrevious ? onPrevious : null,
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(
            Icons.skip_next,
            color: canPlayNext
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            size: 32,
          ),
          onPressed: canPlayNext ? onNext : null,
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(
            loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
            color: _getRepeatColor(),
          ),
          onPressed: onRepeat,
        ),
      ],
    );
  }
}
