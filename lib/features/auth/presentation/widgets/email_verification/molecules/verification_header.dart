import 'package:flutter/material.dart';
import 'package:music_app/features/auth/presentation/widgets/email_verification/atoms/atoms.dart';

/// Molécula: Encabezado de verificación con icono y título
class VerificationHeader extends StatelessWidget {
  final String title;

  const VerificationHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const VerificationIcon(),
        const SizedBox(height: 32),
        TitleText(text: title),
      ],
    );
  }
}
