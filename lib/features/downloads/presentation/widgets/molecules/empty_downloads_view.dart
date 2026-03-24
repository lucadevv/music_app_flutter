import 'package:flutter/material.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/features/downloads/presentation/widgets/atoms/icon_with_text.dart';

/// Molécula: EmptyDownloadsView
///
/// Muestra el estado cuando no hay descargas.
class EmptyDownloadsView extends StatelessWidget {
  const EmptyDownloadsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IconWithText(
      icon: Icons.download_done,
      title: l10n.noDownloadsYet,
      subtitle: l10n.downloadsWillAppearHere,
    );
  }
}
