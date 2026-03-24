import 'package:flutter/material.dart';
import 'package:music_app/l10n/app_localizations.dart';

class ErrorStateMolecule extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const ErrorStateMolecule({
    required this.onRetry,
    this.errorMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage ?? l10n.errorUnknown,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
