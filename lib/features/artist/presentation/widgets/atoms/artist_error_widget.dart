import 'package:flutter/material.dart';
import 'package:music_app/l10n/app_localizations.dart';

class ArtistErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const ArtistErrorWidget({
    required this.errorMessage, required this.onRetry, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? l10n.errorLoadingPlaylist,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
