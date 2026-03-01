import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class UserPlaylistsScreen extends StatefulWidget {
  const UserPlaylistsScreen({super.key});

  @override
  State<UserPlaylistsScreen> createState() => _UserPlaylistsScreenState();
}

class _UserPlaylistsScreenState extends State<UserPlaylistsScreen> {
  List<dynamic> _playlists = []; // Todas las playlists (user + favorites)
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllPlaylists();
  }

  Future<void> _loadAllPlaylists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final libraryService = getIt<LibraryService>();
      
      // Cargar playlists del usuario Y playlists favoritas
      final userPlaylists = await libraryService.getUserPlaylists();
      final favoritePlaylists = await libraryService.getFavoritePlaylists();
      
      if (mounted) {
        setState(() {
          // Recopilar IDs de playlists del usuario
          final userPlaylistIds = userPlaylists.data.map((p) => p.id).toSet();
          
          // Obtener los externalPlaylistIds de las playlists del usuario
          // (para evitar duplicar cuando una playlist de YT se marcó como favorita)
          final userExternalIds = <String>{};
          for (final fav in favoritePlaylists.data) {
            if (userPlaylistIds.contains(fav.playlistId)) {
              userExternalIds.add(fav.externalPlaylistId);
            }
          }
          
          // Filtrar favorites:
          // 1. No está en mis playlists (evitar duplicados por ID interno)
          // 2. No tiene el mismo externalPlaylistId que mis playlists
          // 3. Tiene canciones (evitar vacías)
          final uniqueFavorites = favoritePlaylists.data
              .where((p) => !userPlaylistIds.contains(p.playlistId))  // No está en mis playlists
              .where((p) => (p.cachedTrackCount ?? p.trackCount ?? 0) > 0)  // Tiene canciones
              .toList();
          
          _playlists = [
            ...userPlaylists.data.map((p) => _PlaylistItem(
              id: p.id,
              name: p.name,
              thumbnail: p.thumbnail,
              songCount: p.songCount,
              type: PlaylistType.user,
              externalId: null,
            )),
            ...uniqueFavorites.map((p) => _PlaylistItem(
              id: p.id,
              name: p.name,
              thumbnail: p.thumbnail,
              songCount: p.cachedTrackCount ?? p.trackCount ?? 0,
              type: PlaylistType.favorite,
              externalId: p.externalPlaylistId,
            )),
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createPlaylist(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        title: Text(
          l10n.createPlaylist,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.playlistName,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColorsDark.primary),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: Text(
              l10n.createPlaylist,
              style: const TextStyle(color: AppColorsDark.primary),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final libraryService = getIt<LibraryService>();
        await libraryService.createUserPlaylist(name: result);
        _loadAllPlaylists(); // Recargar
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _navigateToPlaylist(dynamic playlist) {
    if (playlist.type == PlaylistType.user) {
      // Playlist creada por el usuario - navegar a screen de detalles
      context.router.push(UserPlaylistDetailRoute(playlistId: playlist.id));
    } else {
      // Playlist favorita - navegar a la screen existente de YouTube
      context.router.push(PlaylistRoute(id: playlist.externalId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.myPlaylists,
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
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _createPlaylist(context),
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColorsDark.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllPlaylists,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_play,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPlaylistsYet,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createPlaylistToOrganize,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _createPlaylist(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.createPlaylist),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsDark.primary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColorsDark.primary,
      onRefresh: _loadAllPlaylists,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _playlists.length,
        itemBuilder: (context, index) {
          final playlist = _playlists[index];
          return _PlaylistCard(
            playlist: playlist,
            onTap: () => _navigateToPlaylist(playlist),
          );
        },
      ),
    );
  }
}

enum PlaylistType { user, favorite }

class _PlaylistItem {
  final String id;
  final String name;
  final String? thumbnail;
  final int songCount;
  final PlaylistType type;
  final String? externalId;

  _PlaylistItem({
    required this.id,
    required this.name,
    this.thumbnail,
    required this.songCount,
    required this.type,
    this.externalId,
  });
}

class _PlaylistCard extends StatelessWidget {
  final _PlaylistItem playlist;
  final VoidCallback onTap;

  const _PlaylistCard({
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColorsDark.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: playlist.thumbnail != null
                        ? CachedNetworkImage(
                            imageUrl: playlist.thumbnail!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) => _buildPlaceholder(),
                            errorWidget: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // Badge para tipo de playlist
                if (playlist.type == PlaylistType.favorite)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColorsDark.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            playlist.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${playlist.songCount} ${l10n.songs}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColorsDark.primaryContainer,
      child: Center(
        child: Icon(
          Icons.playlist_play,
          size: 48,
          color: AppColorsDark.primary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
