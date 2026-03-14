import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.createAccount,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColorsDark.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.signUpToStart,
          style: const TextStyle(fontSize: 16, color: AppColorsDark.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
