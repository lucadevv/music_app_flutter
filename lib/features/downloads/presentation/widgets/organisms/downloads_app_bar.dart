import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Organismo: DownloadsAppBar
///
/// AppBar de la pantalla de descargas con acciones de settings.
class DownloadsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSettingsPressed;

  const DownloadsAppBar({
    required this.title,
    super.key,
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
          title: Text(AppLocalizations.of(context)!.settings),
          content: const Text(
            'Downloading settings screen is not implemented yet.',
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.router.maybePop(),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }
}
