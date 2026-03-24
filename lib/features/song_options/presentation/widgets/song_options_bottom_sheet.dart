import 'package:music_app/features/song_options/presentation/widgets/atoms/option_tile_atom.dart';
import 'package:music_app/features/song_options/presentation/widgets/molecules/song_header_molecule.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/utils/bottom_sheet_transition.dart';
import 'package:music_app/core/utils/bottom_sheet_visibility.dart';
import 'package:music_app/features/downloads/presentation/widgets/download_option_tile.dart';
import 'package:music_app/features/song_options/presentation/widgets/molecules/favorite_option_molecule.dart';
import 'package:music_app/features/song_options/presentation/widgets/organisms/add_to_playlist_dialog_organism.dart';
import 'package:music_app/l10n/app_localizations.dart';

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
            SongHeaderMolecule(
              title: song.title,
              artist: song.artist,
              thumbnail: song.thumbnail,
            ),
            const Divider(color: Colors.white24),

            // Opción: Like/Unlike
            FavoriteOptionMolecule(
              videoId: song.videoId,
              title: song.title,
              artist: song.artist,
              thumbnail: song.thumbnail,
              duration: song.durationSeconds,
              isFavorite: song.isFavorite,
              streamUrl: song.streamUrl,
            ),

            // Opción: Agregar a playlist
            OptionTileAtom(
              icon: Icons.playlist_add,
              label: l10n.addToPlaylist,
              onTap: () {
                BottomSheetTransition.showNextAsync(
                  context: context,
                  builder: (ctx) => AddToPlaylistDialogOrganism(song: song),
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
            OptionTileAtom(
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
