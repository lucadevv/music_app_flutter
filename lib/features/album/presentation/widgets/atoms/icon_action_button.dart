import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Átomo: Botón de acción con ícono
class IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double iconSize;

  const IconActionButton({
    required this.icon,
    super.key,
    this.iconColor,
    this.iconSize = 24,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: iconColor ?? AppColorsDark.onSurface,
        size: iconSize,
      ),
      onPressed: onPressed,
    );
  }
}
