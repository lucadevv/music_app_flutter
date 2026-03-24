import 'package:flutter/material.dart';
import 'package:music_app/features/auth/email_verification/presentation/widgets/atoms/atoms.dart';

/// Molécula: Botones de acción (abrir email y logout)
class ActionButtons extends StatelessWidget {
  final VoidCallback onOpenEmail;
  final VoidCallback onLogout;
  final String openEmailLabel;
  final String logoutLabel;

  const ActionButtons({
    super.key,
    required this.onOpenEmail,
    required this.onLogout,
    required this.openEmailLabel,
    required this.logoutLabel,
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
