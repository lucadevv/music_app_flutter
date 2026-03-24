import 'package:flutter/material.dart';

/// Organismo: DownloadsAppBar
///
/// AppBar de la pantalla de descargas con acciones de settings.
class DownloadsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSettingsPressed;

  const DownloadsAppBar({
    super.key,
    required this.title,
    this.onSettingsPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettingsPressed ?? () => _showSettingsDialog(context),
        ),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Settings'),
          content: const Text(
            'Downloading settings screen is not implemented yet.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
