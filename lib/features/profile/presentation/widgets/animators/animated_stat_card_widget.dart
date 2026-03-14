import 'package:flutter/material.dart';

/// Animated wrapper for stat card
class AnimatedStatCardWidget extends StatefulWidget {
  final double delay;
  final Widget child;

  const AnimatedStatCardWidget({
    required this.delay, required this.child, super.key,
  });

  @override
  State<AnimatedStatCardWidget> createState() => _AnimatedStatCardWidgetState();
}

class _AnimatedStatCardWidgetState extends State<AnimatedStatCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
