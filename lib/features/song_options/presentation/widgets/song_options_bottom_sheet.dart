import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/bottom_sheet_transition.dart';
import 'package:music_app/core/utils/bottom_sheet_visibility.dart';
import 'package:music_app/features/downloads/presentation/widgets/download_option_tile.dart';
import 'package:music_app/features/favorites/presentation/cubit/favorite_cubit.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';
// Note: Sharing functionality can be wired with 'share_plus' in a future PR

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
    required this.song,
    super.key,
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
  void _shareSong(BuildContext context, SongOptionsData song) {
    final shareText =
        '🎵 ${song.title} - ${song.artist}\n\n'
        'Listen to this song on Music App!\n'
        'https://music.youtube.com/watch?v=${song.videoId}';

    // Share.share(shareText, subject: song.title);

    // For now, show a snackbar as fallback
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Share: $shareText')));
    }
  }

  /// Muestra el diálogo para agregar a playlist
  Future<void> _showAddToPlaylistDialog(
    BuildContext context,
    SongOptionsData song,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final libraryService = getIt<LibraryService>();
    List<UserPlaylist> playlists = [];
    bool isLoading = true;
    String? error;
    String searchQuery = '';

    Future<void> loadPlaylists() async {
      try {
        final response = await libraryService.getUserPlaylists();
        playlists = response.data;
        error = null;
      } catch (e) {
        error = _getErrorMessage(e);
      }
      isLoading = false;
    }

    await loadPlaylists();
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsDark.surfaceContainerHigh,
      isScrollControlled: true,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setState) {
          final filteredPlaylists = searchQuery.isEmpty
              ? playlists
              : playlists
                    .where(
                      (p) => p.name.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: EdgeInsets.only(
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() => searchQuery = value);
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Buscar playlists...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            filled: true,
                            fillColor: AppColorsDark.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CreatePlaylistButton(
                        onCreated: (newPlaylist) async {
                          try {
                            await libraryService.addSongToUserPlaylist(
                              newPlaylist.id,
                              videoId: song.videoId,
                              title: song.title,
                              artist: song.artist,
                              thumbnail: song.thumbnail,
                              duration: song.durationSeconds,
                            );
                            if (bottomSheetContext.mounted) {
                              Navigator.pop(bottomSheetContext);
                              ScaffoldMessenger.of(
                                bottomSheetContext,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${song.title} agregada a ${newPlaylist.name}',
                                  ),
                                  backgroundColor: AppColorsDark.primary,
                                ),
                              );
                            }
                          } catch (e) {
                            if (bottomSheetContext.mounted) {
                              ScaffoldMessenger.of(
                                bottomSheetContext,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error: ${_getErrorMessage(e)}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColorsDark.primary,
                      ),
                    ),
                  )
                else if (error != null)
                  Expanded(
                    child: _ErrorWidget(
                      message: error!,
                      onRetry: () async {
                        setState(() => isLoading = true);
                        await loadPlaylists();
                        setState(() {});
                      },
                    ),
                  )
                else if (filteredPlaylists.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.playlist_play,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            searchQuery.isNotEmpty
                                ? 'No se encontraron playlists'
                                : l10n.noPlaylistsYet,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        setState(() => isLoading = true);
                        await loadPlaylists();
                        setState(() {});
                      },
                      color: AppColorsDark.primary,
                      child: ListView.builder(
                        itemCount: filteredPlaylists.length,
                        itemBuilder: (context, index) {
                          final playlist = filteredPlaylists[index];
                          return _PlaylistTile(
                            playlist: playlist,
                            l10n: l10n,
                            onTap: () async {
                              try {
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
                                  ScaffoldMessenger.of(
                                    bottomSheetContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${song.title} agregada a ${playlist.name}',
                                      ),
                                      backgroundColor: AppColorsDark.primary,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (bottomSheetContext.mounted) {
                                  ScaffoldMessenger.of(
                                    bottomSheetContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error: ${_getErrorMessage(e)}',
                                      ),
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
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection')) {
      return 'Sin conexión a internet';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Tiempo de espera agotado';
    } else if (error.toString().contains('401')) {
      return 'Sesión expirada';
    } else if (error.toString().contains('403')) {
      return 'No tienes permiso para esta acción';
    } else if (error.toString().contains('404')) {
      return 'Playlist no encontrada';
    } else if (error.toString().contains('409')) {
      return 'La canción ya está en esta playlist';
    }
    return 'Error al cargar las playlists';
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
              streamUrl: song.streamUrl,
            ),

            // Opción: Agregar a playlist
            _OptionTile(
              icon: Icons.playlist_add,
              label: l10n.addToPlaylist,
              onTap: () {
                BottomSheetTransition.showNextAsync(
                  context: context,
                  builder: (ctx) => _AddToPlaylistDialogContent(song: song),
                );
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
                _shareSong(context, song);
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
                  errorWidget: (_, _, _) => const Icon(
                    Icons.music_note,
                    color: AppColorsDark.primary,
                  ),
                )
              : const Icon(Icons.music_note, color: AppColorsDark.primary),
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
  final String? streamUrl;

  const _FavoriteOptionTile({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.isFavorite,
    this.thumbnail,
    this.duration,
    this.streamUrl,
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
            streamUrl: streamUrl,
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

class _PlaylistTile extends StatelessWidget {
  final UserPlaylist playlist;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _PlaylistTile({
    required this.playlist,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.playlist_play,
                    color: AppColorsDark.primary,
                  ),
                ),
              )
            : const Icon(Icons.playlist_play, color: AppColorsDark.primary),
      ),
      title: Text(
        playlist.name,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.songCount} ${l10n.songs}',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.add, color: AppColorsDark.primary),
      onTap: onTap,
    );
  }
}

class _CreatePlaylistButton extends StatelessWidget {
  final Function(UserPlaylist) onCreated;

  const _CreatePlaylistButton({required this.onCreated});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsDark.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showCreatePlaylistDialog(context),
        tooltip: 'Crear nueva playlist',
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColorsDark.surfaceContainerHigh,
          title: const Text(
            'Nueva Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: textController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nombre de la playlist',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: AppColorsDark.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre no puede estar vacío';
                }
                if (value.trim().length < 2) {
                  return 'El nombre debe tener al menos 2 caracteres';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsDark.primary,
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() => isLoading = true);
                        try {
                          final libraryService = getIt<LibraryService>();
                          final newPlaylist = await libraryService
                              .createUserPlaylist(
                                name: textController.text.trim(),
                              );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, true);
                            onCreated(newPlaylist);
                          }
                        } catch (e) {
                          setState(() => isLoading = false);
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Error al crear: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Crear', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    textController.dispose();
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsDark.primary,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para el diálogo de agregar a playlist
/// Este es un StatefulWidget independiente para evitar problemas de contexto
class _AddToPlaylistDialogContent extends StatefulWidget {
  final SongOptionsData song;

  const _AddToPlaylistDialogContent({required this.song});

  @override
  State<_AddToPlaylistDialogContent> createState() =>
      _AddToPlaylistDialogContentState();
}

class _AddToPlaylistDialogContentState
    extends State<_AddToPlaylistDialogContent> {
  final _libraryService = getIt<LibraryService>();
  List<UserPlaylist> _playlists = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    try {
      final response = await _libraryService.getUserPlaylists();
      if (mounted) {
        setState(() {
          _playlists = response.data;
          _error = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _getErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection')) {
      return 'Sin conexión a internet';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Tiempo de espera agotado';
    } else if (error.toString().contains('401')) {
      return 'Sesión expirada';
    } else if (error.toString().contains('403')) {
      return 'No tienes permiso para esta acción';
    } else if (error.toString().contains('404')) {
      return 'Playlist no encontrada';
    } else if (error.toString().contains('409')) {
      return 'La canción ya está en esta playlist';
    }
    return 'Error al cargar las playlists';
  }

  Future<void> _addSongToPlaylist(UserPlaylist playlist) async {
    try {
      await _libraryService.addSongToUserPlaylist(
        playlist.id,
        videoId: widget.song.videoId,
        title: widget.song.title,
        artist: widget.song.artist,
        thumbnail: widget.song.thumbnail,
        duration: widget.song.durationSeconds,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.song.title} agregada a ${playlist.name}'),
            backgroundColor: AppColorsDark.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${_getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<UserPlaylist> get _filteredPlaylists {
    if (_searchQuery.isEmpty) return _playlists;
    return _playlists
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
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
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar playlists...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: AppColorsDark.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _CreatePlaylistButton(
                  onCreated: (newPlaylist) async {
                    await _addSongToPlaylist(newPlaylist);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColorsDark.primary),
              ),
            )
          else if (_error != null)
            Expanded(
              child: _ErrorWidget(
                message: _error!,
                onRetry: () {
                  setState(() => _isLoading = true);
                  _loadPlaylists();
                },
              ),
            )
          else if (_filteredPlaylists.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isNotEmpty
                          ? Icons.search_off
                          : Icons.playlist_play,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No se encontraron playlists'
                          : l10n.noPlaylistsYet,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() => _isLoading = true);
                  await _loadPlaylists();
                },
                color: AppColorsDark.primary,
                child: ListView.builder(
                  itemCount: _filteredPlaylists.length,
                  itemBuilder: (context, index) {
                    final playlist = _filteredPlaylists[index];
                    return _PlaylistTile(
                      playlist: playlist,
                      l10n: l10n,
                      onTap: () => _addSongToPlaylist(playlist),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
