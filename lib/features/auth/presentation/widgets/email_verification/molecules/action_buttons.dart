import 'package:flutter/material.dart';
import 'package:music_app/features/auth/presentation/widgets/email_verification/atoms/atoms.dart';

/// Molécula: Botones de acción (abrir email y logout)
class ActionButtons extends StatelessWidget {
  final VoidCallback onOpenEmail;
  final VoidCallback onLogout;
  final String openEmailLabel;
  final String logoutLabel;

  const ActionButtons({
    required this.onOpenEmail,
    required this.onLogout,
    required this.openEmailLabel,
    required this.logoutLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          onPressed: onOpenEmail,
          icon: Icons.email,
          label: openEmailLabel,
        ),
        const SizedBox(height: 16),
        ErrorButton(
          onPressed: onLogout,
          icon: Icons.logout,
          label: logoutLabel,
        ),
      ],
    );
  }
}
