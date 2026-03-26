import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

class DeletePlaylistDialogMolecule extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const DeletePlaylistDialogMolecule({
    required this.onCancel,
    required this.onDelete,
    super.key,
  });

  static Future<bool?> show(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        title: Text(
          l10n.delete,
          style: const TextStyle(color: AppColorsDark.onSurface),
        ),
        content: const Text(
          'Are you sure you want to delete this playlist?',
          style: TextStyle(color: AppColorsDark.onSurface70),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.router.maybePop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => dialogContext.router.maybePop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColorsDark.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: AppColorsDark.surfaceContainerHigh,
      title: Text(
        l10n.delete,
        style: const TextStyle(color: AppColorsDark.onSurface),
      ),
      content: const Text(
        'Are you sure you want to delete this playlist?',
        style: TextStyle(color: AppColorsDark.onSurface70),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
        TextButton(
          onPressed: onDelete,
          child: const Text(
            'Delete',
            style: TextStyle(color: AppColorsDark.error),
          ),
        ),
      ],
    );
  }
}
