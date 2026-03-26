import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/auth/presentation/notifiers/login_form_notifier.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Atom: Email input field
class EmailInput extends StatelessWidget {
  final LoginFormNotifier formNotifier;

  const EmailInput({required this.formNotifier, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: formNotifier,
      builder: (context, _) {
        return TextFormField(
          controller: formNotifier.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.emailAddress,
            hintText: l10n.emailHint,
            prefixIcon: const Icon(
              Icons.email_rounded,
              color: AppColorsDark.primary,
            ),
            filled: true,
            fillColor: AppColorsDark.surfaceContainerHigh,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            labelStyle: const TextStyle(color: AppColorsDark.onSurfaceVariant),
            hintStyle: const TextStyle(color: AppColorsDark.onSurfaceVariant),
            errorText: formNotifier.emailError,
          ),
          style: const TextStyle(color: AppColorsDark.onSurface),
        );
      },
    );
  }
}
