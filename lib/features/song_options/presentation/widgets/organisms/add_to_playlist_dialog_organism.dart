import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/domain/use_cases/add_song_to_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/create_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/get_user_playlists_use_case.dart'
    as lib_usecase;
import 'package:music_app/features/song_options/presentation/widgets/atoms/error_widget_atom.dart';
import 'package:music_app/features/song_options/presentation/widgets/molecules/playlist_tile_molecule.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart'
    show SongOptionsData;
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

/// Organism: Add to playlist dialog content
class AddToPlaylistDialogOrganism extends StatefulWidget {
  final SongOptionsData song;
  final VoidCallback? onSongAdded;
  final VoidCallback? onPlaylistCreated;

  const AddToPlaylistDialogOrganism({
    required this.song, super.key,
    this.onSongAdded,
    this.onPlaylistCreated,
  });

  @override
  State<AddToPlaylistDialogOrganism> createState() =>
      _AddToPlaylistDialogOrganismState();
}

class _AddToPlaylistDialogOrganismState
    extends State<AddToPlaylistDialogOrganism> {
  final _getUserPlaylistsUseCase = getIt<lib_usecase.GetUserPlaylistsUseCase>();
  final _addSongToPlaylistUseCase = getIt<AddSongToUserPlaylistUseCase>();
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
    final result = await _getUserPlaylistsUseCase(limit: 50);
    if (mounted) {
      result.fold(
        (error) {
          setState(() {
            _error = _getErrorMessageFromAppException(error);
            _isLoading = false;
          });
        },
        (playlists) {
          setState(() {
            _playlists = playlists;
            _error = null;
            _isLoading = false;
          });
        },
      );
    }
  }

  String _getErrorMessageFromAppException(AppException error) {
    final errorStr = error.message;
    if (errorStr.contains('SocketException') ||
        errorStr.contains('Connection')) {
      return 'Sin conexión a internet';
    } else if (errorStr.contains('TimeoutException')) {
      return 'Tiempo de espera agotado';
    } else if (errorStr.contains('401')) {
      return 'Sesión expirada';
    } else if (errorStr.contains('403')) {
      return 'No tienes permiso para esta acción';
    } else if (errorStr.contains('404')) {
      return 'Playlist no encontrada';
    } else if (errorStr.contains('409')) {
      return 'La canción ya está en esta playlist';
    }
    return errorStr.isNotEmpty ? errorStr : 'Error al cargar las playlists';
  }



  Future<void> _addSongToPlaylist(UserPlaylist playlist) async {
    final result = await _addSongToPlaylistUseCase(
      playlist.id,
      videoId: widget.song.videoId,
      title: widget.song.title,
      artist: widget.song.artist,
      thumbnail: widget.song.thumbnail,
      duration: widget.song.durationSeconds,
    );

    if (mounted) {
      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${_getErrorMessageFromAppException(error)}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.song.title} agregada a ${playlist.name}'),
              backgroundColor: AppColorsDark.primary,
            ),
          );
          widget.onSongAdded?.call();
        },
      );
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
          _buildHeader(context, l10n),
          const Divider(color: Colors.white24),
          _buildSearchField(l10n),
          const SizedBox(height: 8),
          Expanded(child: _buildContent(l10n)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
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
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Padding(
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
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColorsDark.primary),
      );
    }

    if (_error != null) {
      return ErrorWidgetAtom(
        message: _error!,
        onRetry: () {
          setState(() => _isLoading = true);
          _loadPlaylists();
        },
      );
    }

    if (_filteredPlaylists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.playlist_play,
              size: 48,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron playlists'
                  : l10n.noPlaylistsYet,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        await _loadPlaylists();
      },
      color: AppColorsDark.primary,
      child: ListView.builder(
        itemCount: _filteredPlaylists.length,
        itemBuilder: (context, index) {
          final playlist = _filteredPlaylists[index];
          return PlaylistTileMolecule(
            playlist: playlist,
            onTap: () => _addSongToPlaylist(playlist),
          );
        },
      ),
    );
  }
}

/// Widget para crear nueva playlist
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

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerLow,
        title: const Text(
          'Crear playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nombre de la playlist',
            hintStyle: TextStyle(color: Colors.white54),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final createPlaylistUseCase = getIt<CreateUserPlaylistUseCase>();
      final createResult = await createPlaylistUseCase(
        name: textController.text.trim(),
      );

      createResult.fold(
        (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al crear playlist: ${error.message}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onCreated,
      );
    }
  }
}
