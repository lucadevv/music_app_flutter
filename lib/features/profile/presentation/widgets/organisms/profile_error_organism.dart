import 'package:flutter/material.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Organismo que muestra el estado de error al cargar el perfil.
class ProfileErrorOrganism extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const ProfileErrorOrganism({
    super.key,
    required this.error,
    required this.onRetry,
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
            l10n.errorLoadingProfile,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
