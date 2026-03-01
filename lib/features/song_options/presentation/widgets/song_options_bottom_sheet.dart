import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/bottom_sheet_visibility.dart';
import 'package:music_app/features/downloads/presentation/widgets/download_option_tile.dart';
import 'package:music_app/features/favorites/presentation/cubit/favorite_cubit.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';
// TODO: Importar share_plus cuando esté disponible
// import 'package:share_plus/share_plus.dart';

/// Datos de canción para el bottom sheet
class SongOptionsData {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final String? streamUrl;
  final int? durationSeconds;
  final bool isFavorite;

  const SongOptionsData({
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.streamUrl,
    this.durationSeconds,
    this.isFavorite = false,
  });
}

/// Widget reutilizable para el bottom sheet de opciones de canción
///
/// Incluye: Like/Unlike, Agregar a playlist, Descargar, Compartir
class SongOptionsBottomSheet extends StatelessWidget {
  final SongOptionsData song;
  final VoidCallback? onPlayOffline;
  final VoidCallback? onRemoveDownload;

  const SongOptionsBottomSheet({
    super.key,
    required this.song,
    this.onPlayOffline,
    this.onRemoveDownload,
  });

  /// Muestra el bottom sheet de opciones de canción
  static void show({
    required BuildContext context,
    required SongOptionsData song,
    VoidCallback? onPlayOffline,
    VoidCallback? onRemoveDownload,
  }) {
    BottomSheetVisibility().showBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SongOptionsBottomSheet(
        song: song,
        onPlayOffline: onPlayOffline,
        onRemoveDownload: onRemoveDownload,
      ),
    );
  }

  /// Comparte la canción
  void _shareSong(SongOptionsData song) {
    final shareText = '🎵 ${song.title} - ${song.artist}\n\n'
        'Listen to this song on Music App!\n'
        'https://music.youtube.com/watch?v=${song.videoId}';

    // TODO: Descomentar cuando se ejecute flutter pub get
    // Share.share(shareText, subject: song.title);
    
    // Por ahora mostrar un snackbar
    debugPrint('Share: $shareText');
  }

  /// Muestra el diálogo para agregar a playlist
  Future<void> _showAddToPlaylistDialog(BuildContext context, SongOptionsData song) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Load user's playlists
    List<UserPlaylist> playlists = [];
    bool isLoading = true;
    String? error;

    try {
      final libraryService = getIt<LibraryService>();
      final response = await libraryService.getUserPlaylists();
      playlists = response.data;
      isLoading = false;
    } catch (e) {
      error = e.toString();
      isLoading = false;
    }

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsDark.surfaceContainerHigh,
      isScrollControlled: true,
      builder: (bottomSheetContext) => Container(
        padding: EdgeInsets.only(
          top: 16,
          bottom: MediaQuery.of(bottomSheetContext).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.addToPlaylist,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColorsDark.primary),
                ),
              )
            else if (error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (playlists.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.playlist_play,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noPlaylistsYet,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColorsDark.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: playlist.thumbnail != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: playlist.thumbnail!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.playlist_play,
                                color: AppColorsDark.primary,
                              ),
                      ),
                      title: Text(
                        playlist.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${playlist.songCount} ${l10n.songs}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      onTap: () async {
                        try {
                          final libraryService = getIt<LibraryService>();
                          await libraryService.addSongToUserPlaylist(
                            playlist.id,
                            videoId: song.videoId,
                            title: song.title,
                            artist: song.artist,
                            thumbnail: song.thumbnail,
                            duration: song.durationSeconds,
                          );
                          if (bottomSheetContext.mounted) {
                            Navigator.pop(bottomSheetContext);
                            ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
                              SnackBar(
                                content: Text('${song.title} added to ${playlist.name}'),
                                backgroundColor: AppColorsDark.primary,
                              ),
                            );
                          }
                        } catch (e) {
                          if (bottomSheetContext.mounted) {
                            ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header de la canción
            _SongHeader(
              title: song.title,
              artist: song.artist,
              thumbnail: song.thumbnail,
            ),
            const Divider(color: Colors.white24),

            // Opción: Like/Unlike
            _FavoriteOptionTile(
              videoId: song.videoId,
              title: song.title,
              artist: song.artist,
              thumbnail: song.thumbnail,
              duration: song.durationSeconds,
              isFavorite: song.isFavorite,
            ),

            // Opción: Agregar a playlist
            _OptionTile(
              icon: Icons.playlist_add,
              label: l10n.addToPlaylist,
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistDialog(context, song);
              },
            ),

            // Opción: Descargar
            DownloadOptionTile(
              videoId: song.videoId,
              title: song.title,
              artist: song.artist,
              thumbnail: song.thumbnail,
              streamUrl: song.streamUrl,
              durationSeconds: song.durationSeconds,
              label: l10n.download,
            ),

            // Opción: Compartir
            _OptionTile(
              icon: Icons.share,
              label: l10n.share,
              onTap: () {
                Navigator.pop(context);
                _shareSong(song);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para el header de la canción en el bottom sheet
class _SongHeader extends StatelessWidget {
  final String title;
  final String artist;
  final String? thumbnail;

  const _SongHeader({
    required this.title,
    required this.artist,
    this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 48,
          height: 48,
          color: AppColorsDark.primaryContainer,
          child: thumbnail != null
              ? CachedNetworkImage(
                  imageUrl: thumbnail!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Icon(
                    Icons.music_note,
                    color: AppColorsDark.primary,
                  ),
                )
              : Icon(Icons.music_note, color: AppColorsDark.primary),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        artist,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Widget para la opción de favorito
class _FavoriteOptionTile extends StatelessWidget {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final int? duration;
  final bool isFavorite;

  const _FavoriteOptionTile({
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.duration,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final label = isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos';
    return _OptionTile(
      icon: isFavorite ? Icons.heart_broken : Icons.favorite_border,
      label: label,
      onTap: () {
        Navigator.pop(context);
        // Toggle favorite
        context.read<FavoriteCubit>().toggleFavorite(
          videoId: videoId,
          type: FavoriteType.song,
          isCurrentlyFavorite: isFavorite,
          metadata: SongMetadata(
            title: title,
            artist: artist,
            thumbnail: thumbnail,
            duration: duration,
          ),
        );
      },
    );
  }
}

/// Widget básico para una opción del bottom sheet
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
