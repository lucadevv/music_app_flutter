import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Atom: Forgot password link
class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          context.router.push(const ForgotPasswordRoute());
        },
        child: Text(
          l10n.forgotYourPassword,
          style: const TextStyle(color: AppColorsDark.primary, fontSize: 14),
        ),
      ),
    );
  }
}
