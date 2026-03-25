import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class LinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const LinkButton({required this.label, super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(color: AppColorsDark.primary, fontSize: 14),
      ),
    );
  }
}
