import 'package:flutter/material.dart';

/// Átomo: Botón de like
class LikeButton extends StatelessWidget {
  final bool isLiked;
  final VoidCallback? onPressed;

  const LikeButton({super.key, required this.isLiked, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.white,
      ),
      onPressed: onPressed,
    );
  }
}
