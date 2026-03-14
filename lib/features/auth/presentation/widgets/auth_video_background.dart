import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AuthVideoBackground extends StatefulWidget {
  final bool enableVideo;
  final String videoPath;

  const AuthVideoBackground({
    super.key,
    this.enableVideo = true,
    this.videoPath = 'assets/video/video_login.mp4',
  });

  @override
  State<AuthVideoBackground> createState() => _AuthVideoBackgroundState();
}

class _AuthVideoBackgroundState extends State<AuthVideoBackground>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.enableVideo) {
      WidgetsBinding.instance.addObserver(this);
      // Delay video init to avoid platform connection issues
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _initializeVideo();
      });
    }
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;
    try {
      _videoController = VideoPlayerController.asset(widget.videoPath);
      await _videoController!.initialize();
      if (!mounted) return;
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0);
      await _videoController!.play();
      _videoInitialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enableVideo) return;
    
    // Pause when app goes to background
    if (state == AppLifecycleState.paused) {
      _videoController?.pause();
    }
    // Resume when app comes back to foreground
    else if (state == AppLifecycleState.resumed) {
      _videoController?.play();
    }
  }

  @override
  void dispose() {
    if (widget.enableVideo) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableVideo ||
        !_videoInitialized ||
        _videoController == null ||
        !_videoController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }
}
