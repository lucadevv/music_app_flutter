import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/downloads/presentation/cubit/downloads_cubit.dart';
import 'package:music_app/features/downloads/presentation/widgets/download_progress_widget.dart';
import 'package:music_app/features/downloads/presentation/widgets/downloaded_song_item_widget.dart';
import 'package:music_app/l10n/app_localizations.dart';

import '../../domain/entities/downloaded_song.dart';

/// Pantalla de descargas
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar la lista de canciones descargadas
@RoutePage()
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    // Usar el provider global de DownloadsCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DownloadsCubit>().loadDownloads();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<DownloadsCubit, DownloadsState>(
      builder: (context, state) {
        if (state.status == DownloadsStatus.initial ||
            state.status == DownloadsStatus.loading) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.downloads)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.downloads),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // Abre un diálogo simple para indicar que la funcionalidad aún no está implementada
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Settings'),
                        content: const Text(
                          'Downloading settings screen is not implemented yet.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: _DownloadsBody(l10n: l10n),
        );
      }, // end of builder
    );
  }
}

class _DownloadsBody extends StatelessWidget {
  final AppLocalizations l10n;

  const _DownloadsBody({required this.l10n});

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
          Icon(Icons.download_done, size: 80, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            l10n.noDownloadsYet,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.downloadsWillAppearHere,
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
          Icon(Icons.error_outline, size: 80, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            l10n.errorOccurred,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ?? l10n.errorUnknown,
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
            child: Text(l10n.retry),
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
                  l10n.downloadingTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...state.downloadingIds.map(
                  (videoId) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DownloadProgressWidget(
                      progress: state.downloadProgress[videoId] ?? 0,
                      title: '${l10n.song} $videoId',
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
                  // Usar el método del Cubit para reproducir
                  final nowPlayingData = context
                      .read<DownloadsCubit>()
                      .playDownloadedSong(song);
                  context.router.push(
                    PlayerRoute(nowPlayingData: nowPlayingData),
                  );
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
    BuildContext context,
    DownloadedSong song,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteDownloadConfirmation),
          content: Text(l10n.deleteDownloadMessage(song.title)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<DownloadsCubit>().removeDownload(song.videoId);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.deleteDownload),
            ),
          ],
        );
      },
    );
  }
}
