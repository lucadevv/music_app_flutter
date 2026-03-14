import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

class LoginLink extends StatelessWidget {
  const LoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return TextButton(
      onPressed: () {
        context.router.pop();
      },
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColorsDark.onSurfaceVariant, fontSize: 14),
          children: [
            TextSpan(text: '${l10n.alreadyHaveAccount} '),
            TextSpan(
              text: l10n.signIn,
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
