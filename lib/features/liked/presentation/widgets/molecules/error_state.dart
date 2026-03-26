import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final String retryText;
  final VoidCallback? onRetry;

  const ErrorState({
    required this.message,
    required this.retryText,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColorsDark.error, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColorsDark.onSurface70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsDark.primary,
            ),
            child: Text(retryText),
          ),
        ],
      ),
    );
  }
}
