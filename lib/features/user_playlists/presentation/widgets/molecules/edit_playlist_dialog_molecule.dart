import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

class EditPlaylistDialogMolecule extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const EditPlaylistDialogMolecule({
    required this.nameController,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  static Future<void> show(
    BuildContext context,
    String currentName,
    Function(String) onSave,
  ) {
    final nameController = TextEditingController(text: currentName);
    final l10n = AppLocalizations.of(context)!;

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        title: Text(l10n.edit, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.playlistName,
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onSave(nameController.text);
            },
            child: Text(
              l10n.save,
              style: const TextStyle(color: AppColorsDark.primary),
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
      title: Text(l10n.edit, style: const TextStyle(color: Colors.white)),
      content: TextField(
        controller: nameController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: l10n.playlistName,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
        TextButton(
          onPressed: onSave,
          child: Text(
            l10n.save,
            style: const TextStyle(color: AppColorsDark.primary),
          ),
        ),
      ],
    );
  }
}
