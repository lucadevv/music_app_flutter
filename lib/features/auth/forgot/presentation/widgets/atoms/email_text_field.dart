import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const EmailTextField({super.key, required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: l10n.emailLabel,
        hintText: l10n.emailPlaceholder,
        prefixIcon: const Icon(Icons.email, color: AppColorsDark.primary),
        filled: true,
        fillColor: AppColorsDark.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: AppColorsDark.onSurfaceVariant),
        hintStyle: const TextStyle(color: AppColorsDark.onSurfaceVariant),
      ),
      style: const TextStyle(color: AppColorsDark.onSurface),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseEnterEmail;
            }
            if (!value.contains('@')) {
              return l10n.enterValidEmail;
            }
            return null;
          },
    );
  }
}
