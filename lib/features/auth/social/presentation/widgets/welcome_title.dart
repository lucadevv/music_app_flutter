// Molecule: WelcomeTitle
// Represents the welcome title and subtitle text

import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

class WelcomeTitle extends StatelessWidget {
  const WelcomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          l10n.welcome,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColorsDark.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.signInToContinue,
          style: const TextStyle(
            fontSize: 16,
            color: AppColorsDark.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
