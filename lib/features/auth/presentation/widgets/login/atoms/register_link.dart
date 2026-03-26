import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Atom: Register link button
class RegisterLink extends StatelessWidget {
  const RegisterLink({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextButton(
      onPressed: () {
        context.router.push(const RegisterRoute());
      },
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: AppColorsDark.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          children: [
            TextSpan(text: '${l10n.noAccount} '),
            TextSpan(
              text: l10n.register,
              style: const TextStyle(
                color: AppColorsDark.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
