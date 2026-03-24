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
        title: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this playlist?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
      title: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
      content: const Text(
        'Are you sure you want to delete this playlist?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
        TextButton(
          onPressed: onDelete,
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
