import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/downloads/presentation/cubit/downloads_cubit.dart';
import 'package:music_app/features/downloads/presentation/widgets/downloaded_song_item_widget.dart';
import 'package:music_app/features/downloads/presentation/widgets/download_progress_widget.dart';

/// Pantalla de descargas
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar la lista de canciones descargadas
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  DownloadsCubit? _downloadsCubit;

  @override
  void initState() {
    super.initState();
    _initCubit();
  }

  @override
  void dispose() {
    _downloadsCubit?.close();
    super.dispose();
  }

  Future<void> _initCubit() async {
    _downloadsCubit = await GetIt.I.getAsync<DownloadsCubit>();
    _downloadsCubit!.loadDownloads();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_downloadsCubit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Descargas')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider.value(
      value: _downloadsCubit!,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Descargas'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                // TODO: Abrir configuración de descargas
              },
            ),
          ],
        ),
        body: const _DownloadsBody(),
      ),
    );
  }
}

class _DownloadsBody extends StatelessWidget {
  const _DownloadsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadsCubit, DownloadsState>(
      builder: (context, state) {
        if (state.isLoading && !state.hasActiveDownloads) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isFailure && !state.hasDownloads) {
          return _buildErrorState(context, state);
        }

        if (!state.hasDownloads && !state.hasActiveDownloads) {
          return _buildEmptyState(context);
        }

        return _buildDownloadsList(context, state);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_done,
            size: 80,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin descargas aún',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Las canciones que descargues aparecerán aquí',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DownloadsState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Ocurrió un error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ?? 'Error desconocido',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context.read<DownloadsCubit>().loadDownloads();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsList(BuildContext context, DownloadsState state) {
    return Column(
      children: [
        // Descargas activas
        if (state.hasActiveDownloads) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descargando',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...state.downloadingIds.map(
                  (videoId) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DownloadProgressWidget(
                      progress: state.downloadProgress[videoId] ?? 0,
                      title: 'Canción $videoId',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
        ],

        // Lista de descargadas
        Expanded(
          child: ListView.builder(
            itemCount: state.downloadedSongs.length,
            itemBuilder: (context, index) {
              final song = state.downloadedSongs[index];
              final isDownloading = state.downloadingIds.contains(song.videoId);
              final progress = state.downloadProgress[song.videoId] ?? 0.0;

              return DownloadedSongItemWidget(
                song: song,
                isDownloading: isDownloading,
                progress: progress,
                onTap: () {
                  // TODO: Reproducir canción descargada
                },
                onDelete: () {
                  _showDeleteConfirmationDialog(context, song);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, DownloadedSong song) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar descarga'),
          content: Text(
            '¿Estás seguro de que quieres eliminar "${song.title}" de tus descargas?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<DownloadsCubit>().removeDownload(song.videoId);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
