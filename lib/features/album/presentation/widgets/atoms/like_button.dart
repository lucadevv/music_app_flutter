import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Átomo: Botón de like
class LikeButton extends StatelessWidget {
  final bool isLiked;
  final VoidCallback? onPressed;

  const LikeButton({required this.isLiked, super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? AppColorsDark.error : AppColorsDark.onSurface,
      ),
      onPressed: onPressed,
    );
  }
}
