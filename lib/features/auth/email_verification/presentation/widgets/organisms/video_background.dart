import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:video_player/video_player.dart';

/// Organismo: Video background con blur overlay
class VideoBackground extends StatelessWidget {
  final VideoPlayerController? controller;
  final bool enableVideo;

  const VideoBackground({super.key, this.controller, this.enableVideo = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Background
        if (enableVideo &&
            controller != null &&
            controller!.value.isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.size.width,
                height: controller!.value.size.height,
                child: VideoPlayer(controller!),
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
