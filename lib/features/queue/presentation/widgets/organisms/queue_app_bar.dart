import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Organism: Queue screen app bar
class QueueAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String clearLabel;
  final VoidCallback onClear;
  final VoidCallback onBack;

  const QueueAppBar({
    required this.title,
    required this.clearLabel,
    required this.onClear,
    required this.onBack,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColorsDark.onSurface,
        ),
        onPressed: onBack,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColorsDark.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClear,
          child: Text(
            clearLabel,
            style: const TextStyle(color: AppColorsDark.onSurface),
          ),
        ),
      ],
    );
  }
}
