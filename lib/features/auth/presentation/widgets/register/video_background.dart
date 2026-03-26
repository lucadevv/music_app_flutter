import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:video_player/video_player.dart';

class VideoBackground extends StatelessWidget {
  final VideoPlayerController? videoController;
  final bool enableVideo;

  const VideoBackground({
    super.key,
    this.videoController,
    this.enableVideo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Background
        if (enableVideo &&
            videoController != null &&
            videoController!.value.isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoController!.value.size.width,
                height: videoController!.value.size.height,
                child: VideoPlayer(videoController!),
              ),
            ),
          ),

        // Blur overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(color: AppColorsDark.surface.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
