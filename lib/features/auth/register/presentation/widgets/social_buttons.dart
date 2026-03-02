import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

class SocialButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;

  const SocialButtons({super.key, this.onGooglePressed, this.onApplePressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onGooglePressed,
            icon: const Icon(
              Icons.g_mobiledata,
              color: AppColorsDark.onSurface,
            ),
            label: Text(l10n.google),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorsDark.onSurface,
              side: const BorderSide(color: AppColorsDark.outline),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onApplePressed,
            icon: const Icon(Icons.apple, color: AppColorsDark.onSurface),
            label: Text(l10n.apple),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorsDark.onSurface,
              side: const BorderSide(color: AppColorsDark.outline),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
