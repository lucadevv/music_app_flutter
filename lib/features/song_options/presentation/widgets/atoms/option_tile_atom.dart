import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Atom: Basic option tile for bottom sheet actions
class OptionTileAtom extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const OptionTileAtom({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColorsDark.onSurface70),
      title: Text(
        label,
        style: const TextStyle(color: AppColorsDark.onSurface),
      ),
      onTap: onTap,
    );
  }
}
