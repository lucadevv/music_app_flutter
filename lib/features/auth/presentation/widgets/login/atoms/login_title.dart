import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Atom: Login title with gradient effect
class LoginTitle extends StatelessWidget {
  const LoginTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColorsDark.primary, AppColorsDark.onSurface],
      ).createShader(bounds),
      child: Text(
        l10n.loginTitle,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColorsDark.onSurface,
        ),
      ),
    );
  }
}
