import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class SocialButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;

  const SocialButtons({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onGooglePressed,
            icon: Icon(
              Icons.g_mobiledata,
              color: AppColorsDark.onSurface,
            ),
            label: const Text('Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorsDark.onSurface,
              side: BorderSide(color: AppColorsDark.outline),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onApplePressed,
            icon: Icon(
              Icons.apple,
              color: AppColorsDark.onSurface,
            ),
            label: const Text('Apple'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorsDark.onSurface,
              side: BorderSide(color: AppColorsDark.outline),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
