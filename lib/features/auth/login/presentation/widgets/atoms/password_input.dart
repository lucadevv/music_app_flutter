import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/auth/login/presentation/notifiers/login_form_notifier.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Atom: Password input field with visibility toggle
class PasswordInput extends StatefulWidget {
  final LoginFormNotifier formNotifier;

  const PasswordInput({required this.formNotifier, super.key});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: widget.formNotifier,
      builder: (context, _) {
        return TextFormField(
          controller: widget.formNotifier.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: l10n.passwordLabel,
            hintText: l10n.passwordHint,
            prefixIcon: const Icon(
              Icons.lock_rounded,
              color: AppColorsDark.primary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: AppColorsDark.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: AppColorsDark.surfaceContainerHigh,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            labelStyle: const TextStyle(color: AppColorsDark.onSurfaceVariant),
            hintStyle: const TextStyle(color: AppColorsDark.onSurfaceVariant),
            errorText: widget.formNotifier.passwordError,
          ),
          style: const TextStyle(color: AppColorsDark.onSurface),
        );
      },
    );
  }
}
