import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const ActionIconButton({required this.icon, super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: AppColorsDark.onSurface),
      onPressed: onTap,
    );
  }
}
