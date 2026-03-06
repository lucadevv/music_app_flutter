import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

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
    required this.isPlaying,
    required this.canPlayNext,
    required this.canPlayPrevious,
    required this.isShuffleEnabled,
    required this.loopMode,
    super.key,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onShuffle,
    this.onRepeat,
  });

  Color _getRepeatColor() {
    switch (loopMode) {
      case LoopMode.off:
        return AppColorsDark.onSurfaceVariant;
      case LoopMode.one:
        return AppColorsDark.primary;
      case LoopMode.all:
        return AppColorsDark.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColorsDark.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: onShuffle == null
                  ? AppColorsDark.onSurfaceVariant.withValues(alpha: 0.3)
                  : (isShuffleEnabled ? AppColorsDark.primary : AppColorsDark.onSurfaceVariant),
            ),
            onPressed: onShuffle,
          ),
          IconButton(
            icon: Icon(
              Icons.skip_previous,
              color: canPlayPrevious
                  ? AppColorsDark.onSurface
                  : AppColorsDark.onSurfaceVariant.withValues(alpha: 0.3),
              size: 32,
            ),
            onPressed: canPlayPrevious ? onPrevious : null,
          ),
          GestureDetector(
            onTap: onPlayPause,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColorsDark.outlineVariant,
                  width: 1,
                ),
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColorsDark.onSurface,
                size: 36,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.skip_next,
              color: canPlayNext
                  ? AppColorsDark.onSurface
                  : AppColorsDark.onSurfaceVariant.withValues(alpha: 0.3),
              size: 32,
            ),
            onPressed: canPlayNext ? onNext : null,
          ),
          IconButton(
            icon: Icon(
              loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
              color: onRepeat == null
                  ? AppColorsDark.onSurfaceVariant.withValues(alpha: 0.3)
                  : _getRepeatColor(),
            ),
            onPressed: onRepeat,
          ),
        ],
      ),
    );
  }
}
