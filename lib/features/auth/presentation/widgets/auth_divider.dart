import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColorsDark.outlineVariant,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text(
            l10n.or,
            style: const TextStyle(
              color: AppColorsDark.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColorsDark.outlineVariant,
          ),
        ),
      ],
    );
  }
}
