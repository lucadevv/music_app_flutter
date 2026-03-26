import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/downloads/presentation/cubit/downloads_cubit.dart';
import 'package:music_app/features/downloads/presentation/widgets/molecules/downloads_loading_view.dart';
import 'package:music_app/features/downloads/presentation/widgets/molecules/empty_downloads_view.dart';
import 'package:music_app/features/downloads/presentation/widgets/molecules/error_downloads_view.dart';
import 'package:music_app/features/downloads/presentation/widgets/organisms/active_downloads_section.dart';
import 'package:music_app/features/downloads/presentation/widgets/organisms/downloads_app_bar.dart';
import 'package:music_app/features/downloads/presentation/widgets/organisms/downloads_list.dart';
import 'package:music_app/l10n/app_localizations.dart';

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
            body: const DownloadsLoadingView(),
          );
        }

        return Scaffold(
          appBar: DownloadsAppBar(title: l10n.downloads),
          body: _DownloadsBody(l10n: l10n),
        );
      },
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
          return const DownloadsLoadingView();
        }

        if (state.isFailure && !state.hasDownloads) {
          return ErrorDownloadsViewWithRetry(
            errorMessage: state.errorMessage,
            onRetry: () => context.read<DownloadsCubit>().loadDownloads(),
          );
        }

        if (!state.hasDownloads && !state.hasActiveDownloads) {
          return const EmptyDownloadsView();
        }

        return _buildDownloadsContent(context, state);
      },
    );
  }

  Widget _buildDownloadsContent(BuildContext context, DownloadsState state) {
    final cubit = context.read<DownloadsCubit>();

    return Column(
      children: [
        // Descargas activas
        if (state.hasActiveDownloads)
          ActiveDownloadsSection(
            downloadingIds: state.downloadingIds,
            downloadProgress: state.downloadProgress,
            l10n: l10n,
          ),

        // Lista de descargas
        DownloadsListWithNavigation(
          downloadedSongs: state.downloadedSongs,
          downloadingIds: state.downloadingIds,
          downloadProgress: state.downloadProgress,
          playDownloadedSong: cubit.playDownloadedSong,
          onDelete: (song) => _showDeleteConfirmationDialog(context, song),
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
              onPressed: () => dialogContext.router.maybePop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                dialogContext.router.maybePop();
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
