import 'package:flutter/material.dart';
import 'package:music_app/features/auth/presentation/widgets/email_verification/atoms/atoms.dart';
import 'package:music_app/features/auth/presentation/widgets/email_verification/molecules/molecules.dart';

/// Organismo: Contenido principal de verificación de email
class VerificationContent extends StatelessWidget {
  final String title;
  final String description;
  final String? email;
  final bool isLoadingEmail;
  final VoidCallback onOpenEmail;
  final VoidCallback onLogout;
  final String openEmailLabel;
  final String logoutLabel;
  final String additionalInfo;

  const VerificationContent({
    required this.title,
    required this.description,
    required this.onOpenEmail,
    required this.onLogout,
    required this.openEmailLabel,
    required this.logoutLabel,
    required this.additionalInfo,
    super.key,
    this.email,
    this.isLoadingEmail = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icono y título
          VerificationHeader(title: title),
          const SizedBox(height: 16),

          // Descripción y email
          VerificationDescription(
            description: description,
            email: email,
            isLoadingEmail: isLoadingEmail,
          ),
          const SizedBox(height: 32),

          // Botones de acción
          ActionButtons(
            onOpenEmail: onOpenEmail,
            onLogout: onLogout,
            openEmailLabel: openEmailLabel,
            logoutLabel: logoutLabel,
          ),
          const SizedBox(height: 24),

          // Mensaje adicional
          DescriptionText(text: additionalInfo),
        ],
      ),
    );
  }
}
