import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Átomo: Botón de acción destructiva (logout)
class ErrorButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const ErrorButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColorsDark.error),
      label: Text(label, style: const TextStyle(color: AppColorsDark.error)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColorsDark.error),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
