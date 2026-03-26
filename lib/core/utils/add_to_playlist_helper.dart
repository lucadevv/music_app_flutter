import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';

/// Helper centralizado para mostrar el bottom sheet de agregar a playlist
///
/// Asegura consistencia en todas las pantallas de la app
class AddToPlaylistHelper {
  /// Muestra el diálogo de agregar a playlist para una canción
  ///
  /// Usage:
  /// ```dart
  /// AddToPlaylistHelper.show(
  ///   context: context,
  ///   videoId: song.videoId,
  ///   title: song.title,
  ///   artist: song.artist,
  ///   thumbnail: song.thumbnail,
  ///   durationSeconds: song.duration,
  /// );
  /// ```
  static void show({
    required BuildContext context,
    required String videoId,
    required String title,
    required String artist,
    String? thumbnail,
    int? durationSeconds,
    bool isFavorite = false,
    VoidCallback? onPlayOffline,
    VoidCallback? onRemoveDownload,
  }) {
    if (!context.mounted) return;

    try {
      SongOptionsBottomSheet.show(
        context: context,
        song: SongOptionsData(
          videoId: videoId,
          title: title,
          artist: artist,
          thumbnail: thumbnail,
          durationSeconds: durationSeconds,
          isFavorite: isFavorite,
        ),
        onPlayOffline: onPlayOffline,
        onRemoveDownload: onRemoveDownload,
      );
    } catch (e) {
      debugPrint('Error showing AddToPlaylist bottom sheet: $e');
    }
  }

  /// Muestra el diálogo de agregar a playlist de forma segura
  ///
  /// Versión con verificación adicional usando postFrameCallback
  /// Útil cuando hay problemas de timing con el context
  static void showSafe({
    required BuildContext context,
    required String videoId,
    required String title,
    required String artist,
    String? thumbnail,
    int? durationSeconds,
    bool isFavorite = false,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      try {
        SongOptionsBottomSheet.show(
          context: context,
          song: SongOptionsData(
            videoId: videoId,
            title: title,
            artist: artist,
            thumbnail: thumbnail,
            durationSeconds: durationSeconds,
            isFavorite: isFavorite,
          ),
        );
      } catch (e) {
        debugPrint('Error showing AddToPlaylist bottom sheet (safe): $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al abrir opciones: $e'),
              backgroundColor: AppColorsDark.error,
            ),
          );
        }
      }
    });
  }
}
