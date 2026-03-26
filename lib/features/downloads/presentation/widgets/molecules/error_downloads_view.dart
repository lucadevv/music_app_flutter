import 'package:flutter/material.dart';
import 'package:music_app/features/downloads/presentation/widgets/atoms/icon_with_text.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Molécula: ErrorDownloadsView
///
/// Muestra el estado de error con opción de reintentar.
class ErrorDownloadsView extends StatelessWidget {
  final String? errorMessage;

  const ErrorDownloadsView({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return IconWithText(
      icon: Icons.error_outline,
      title: l10n.errorOccurred,
      subtitle: errorMessage ?? l10n.errorUnknown,
      iconColor: colorScheme.error,
    );
  }
}

/// Widget que incluye el botón de retry.
class ErrorDownloadsViewWithRetry extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const ErrorDownloadsViewWithRetry({
    required this.onRetry,
    super.key,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            l10n.errorOccurred,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? l10n.errorUnknown,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
