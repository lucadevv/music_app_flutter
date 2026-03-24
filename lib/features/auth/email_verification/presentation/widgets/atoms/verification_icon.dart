import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Átomo: Icono de verificación de email
class VerificationIcon extends StatelessWidget {
  const VerificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.mark_email_unread,
      size: 80,
      color: AppColorsDark.primary,
    );
  }
}
