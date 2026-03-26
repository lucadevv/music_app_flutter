import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Atom: Login subtitle text
class LoginSubtitle extends StatelessWidget {
  const LoginSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Text(
      l10n.enterYourCredentials,
      style: TextStyle(
        fontSize: 16,
        color: AppColorsDark.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}
