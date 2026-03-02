import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

// Esta pantalla ha sido reemplazada por la nueva en features/downloads/
// Se mantiene aquí por compatibilidad pero ya no tiene @RoutePage()
// La ruta DownloadsRoute ahora apunta a la nueva pantalla
@RoutePage()
class OldDownloadsScreen extends StatelessWidget {
  const OldDownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.downloads,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.router.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              l10n.clear,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 15,
        itemBuilder: (context, index) {
          return _DownloadItem(
            title: '${l10n.downloaded} ${index + 1}',
            artist: '${l10n.artistName} ${index + 1}',
            isDownloaded: true,
          );
        },
      ),
    );
  }
}

class _DownloadItem extends StatelessWidget {
  final String title;
  final String artist;
  final bool isDownloaded;

  const _DownloadItem({
    required this.title,
    required this.artist,
    required this.isDownloaded,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColorsDark.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note, color: AppColorsDark.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDownloaded)
            Icon(Icons.check_circle, color: AppColorsDark.primary, size: 20),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
