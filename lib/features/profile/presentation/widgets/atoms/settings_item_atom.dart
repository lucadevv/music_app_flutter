import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class SettingsItemAtom extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsItemAtom({
    required this.icon,
    required this.title,
    super.key,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: AppColorsDark.onSurface),
      title: Text(
        title,
        style: const TextStyle(color: AppColorsDark.onSurface, fontSize: 16),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: AppColorsDark.onSurface.withValues(alpha: 0.6),
          ),
      onTap: onTap,
    );
  }
}
