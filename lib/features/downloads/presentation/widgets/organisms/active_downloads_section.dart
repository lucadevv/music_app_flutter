import 'package:flutter/material.dart';
import 'package:music_app/features/downloads/presentation/widgets/download_progress_widget.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Organismo: ActiveDownloadsSection
///
/// Muestra la sección de descargas activas con progreso.
class ActiveDownloadsSection extends StatelessWidget {
  final Set<String> downloadingIds;
  final Map<String, double> downloadProgress;
  final AppLocalizations l10n;

  const ActiveDownloadsSection({
    required this.downloadingIds, required this.downloadProgress, required this.l10n, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.downloadingTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...downloadingIds.map(
                (videoId) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DownloadProgressWidget(
                    progress: downloadProgress[videoId] ?? 0,
                    title: '${l10n.song} $videoId',
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
