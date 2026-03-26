import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Diálogo para crear una nueva playlist.
class CreatePlaylistDialog extends StatelessWidget {
  const CreatePlaylistDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => const CreatePlaylistDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    return AlertDialog(
      backgroundColor: AppColorsDark.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.createPlaylist,
        style: const TextStyle(
          color: AppColorsDark.onSurface,
          fontFamily: 'Poppins',
        ),
      ),
      content: TextField(
        controller: nameController,
        style: const TextStyle(color: AppColorsDark.onSurface),
        decoration: InputDecoration(
          hintText: l10n.playlistName,
          hintStyle: TextStyle(
            color: AppColorsDark.onSurface.withValues(alpha: 0.5),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColorsDark.onSurface.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColorsDark.primary),
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => context.router.maybePop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => context.router.maybePop(nameController.text),
          child: Text(
            l10n.createPlaylist,
            style: const TextStyle(color: AppColorsDark.primary),
          ),
        ),
      ],
    );
  }
}
