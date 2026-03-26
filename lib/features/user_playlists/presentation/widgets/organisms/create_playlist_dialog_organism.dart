import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

class CreatePlaylistDialogOrganism extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  const CreatePlaylistDialogOrganism({
    required this.nameController,
    required this.onCancel,
    required this.onCreate,
    super.key,
  });

  static Future<String?> show(BuildContext context) async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => CreatePlaylistDialogOrganism(
        nameController: nameController,
        onCancel: () => dialogContext.router.maybePop(),
        onCreate: () => dialogContext.router.maybePop(nameController.text),
      ),
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: AppColorsDark.surfaceContainerHigh,
      title: Text(
        l10n.createPlaylist,
        style: const TextStyle(color: AppColorsDark.onSurface),
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
        TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
        TextButton(
          onPressed: onCreate,
          child: Text(
            l10n.createPlaylist,
            style: const TextStyle(color: AppColorsDark.primary),
          ),
        ),
      ],
    );
  }
}
