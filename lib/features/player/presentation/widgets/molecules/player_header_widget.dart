import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Widget para el header del reproductor
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar el header con botones de navegación
class PlayerHeaderWidget extends StatelessWidget {
  final String? playlistId;
  final String? playlistName;
  final int currentIndex;
  final int totalTracks;

  const PlayerHeaderWidget({
    super.key,
    this.playlistId,
    this.playlistName,
    this.currentIndex = 0,
    this.totalTracks = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => context.router.pop(),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Music Player',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (playlistName != null)
                Text(
                  playlistName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (totalTracks > 0)
                Text(
                  '${currentIndex + 1}/$totalTracks',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.playlist_add, color: Colors.white),
                onPressed: () {
                
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Add to playlist'),
                      backgroundColor: AppColorsDark.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.queue_music, color: Colors.white),
                onPressed: () {
                  context.router.push(const QueueRoute());
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => _showPlayerMenu(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPlayerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsDark.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                final shareText = playlistName != null 
                    ? 'Check out this playlist: $playlistName'
                    : 'Check out this song';
                Clipboard.setData(ClipboardData(text: shareText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Copied to clipboard'),
                    backgroundColor: AppColorsDark.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Add to playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.white),
              title: const Text('View queue', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                context.router.push(const QueueRoute());
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
