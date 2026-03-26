import 'package:flutter/material.dart';
import 'package:music_app/features/auth/presentation/widgets/email_verification/atoms/atoms.dart';

/// Molécula: Descripción de verificación con email
class VerificationDescription extends StatelessWidget {
  final String description;
  final String? email;
  final bool isLoadingEmail;

  const VerificationDescription({
    required this.description,
    super.key,
    this.email,
    this.isLoadingEmail = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DescriptionText(text: description),
        if (email != null && !isLoadingEmail) ...[
          const SizedBox(height: 8),
          EmailDisplayText(email: email!),
        ],
      ],
    );
  }
}
