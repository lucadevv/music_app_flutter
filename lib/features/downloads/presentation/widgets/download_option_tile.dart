import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/bottom_sheet_visibility.dart';
import 'package:music_app/features/downloads/presentation/cubit/downloads_cubit.dart';

/// Widget de opción de descarga para usar en menús de 3 puntos
///
/// Muestra el estado de descarga y permite iniciar/cancelar descargas
/// Si no hay streamUrl, la obtiene automáticamente del backend
class DownloadOptionTile extends StatefulWidget {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final String? streamUrl;
  final int? durationSeconds;
  final String label;
  final IconData icon;
  final Color? iconColor;

  const DownloadOptionTile({
    required this.videoId,
    required this.title,
    required this.artist,
    super.key,
    this.thumbnail,
    this.streamUrl,
    this.durationSeconds,
    this.label = 'Descargar',
    this.icon = Icons.download_outlined,
    this.iconColor,
  });

  @override
  State<DownloadOptionTile> createState() => _DownloadOptionTileState();
}

class _DownloadOptionTileState extends State<DownloadOptionTile> {
  DownloadsCubit? _cubit;
  bool _isLoadingStreamUrl = false;
  String? _streamUrl;
  bool _isInitialized = false;
  StreamSubscription<DownloadsState>? _subscription;

  @override
  void initState() {
    super.initState();
    _streamUrl = widget.streamUrl;
    _initCubit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _initCubit() async {
    try {
      // Intentar usar el provider global primero
      _cubit = context.read<DownloadsCubit>();

      // Subscribe to stream to keep UI updated
      _subscription = _cubit!.stream.listen((state) {
        if (mounted) {
          setState(() {}); // Rebuild on state changes
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Provider no disponible - usar getIt (fallback para backward compatibility)
      try {
        _cubit = await GetIt.I.getAsync<DownloadsCubit>();

        _subscription = _cubit!.stream.listen((state) {
          if (mounted) {
            setState(() {});
          }
        });

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error initializing DownloadsCubit: $e');
        }
        // Retry after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await _initCubit();
        }
      }
    }
  }

  Future<String?> _getStreamUrl() async {
    if (_streamUrl != null && _streamUrl!.isNotEmpty) {
      return _streamUrl;
    }

    if (_isLoadingStreamUrl) return null;

    setState(() {
      _isLoadingStreamUrl = true;
    });

    try {
      final apiServices = GetIt.I.get<ApiServices>();
      final response = await apiServices.get('/music/stream/${widget.videoId}');
      // ignore: avoid_dynamic_calls
      final data = response is Map ? response : (response.data as Map?);

      if (data != null) {
        final streamUrl = data['streamUrl'] as String?;
        if (streamUrl != null && streamUrl.isNotEmpty) {
          setState(() {
            _streamUrl = streamUrl;
            _isLoadingStreamUrl = false;
          });
          return streamUrl;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting stream URL: $e');
      }
    }

    setState(() {
      _isLoadingStreamUrl = false;
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // If not initialized, show loading
    if (!_isInitialized || _cubit == null) {
      return const ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Cargando...', style: TextStyle(color: Colors.white)),
      );
    }

    // Get current state directly from cubit (this is the latest state)
    final state = _cubit!.state;

    // Verificar si hay coincidencia exacta (incluyendo espacios)
    state.downloadedSongs.any((s) => s.videoId.trim() == widget.videoId.trim());
    state.downloadingIds.any((id) => id.trim() == widget.videoId.trim());

    // Listen to stream for real-time updates while bottom sheet is open
    return StreamBuilder<DownloadsState>(
      stream: _cubit!.stream,
      builder: (context, snapshot) {
        // Use latest state from stream if available, otherwise use cached state
        final latestState = snapshot.data ?? state;
        final currentIsDownloaded = latestState.downloadedSongs.any(
          (s) => s.videoId.trim() == widget.videoId.trim(),
        );
        final currentIsDownloading = latestState.downloadingIds.any(
          (id) => id.trim() == widget.videoId.trim(),
        );
        final currentProgress =
            latestState.downloadProgress[widget.videoId] ??
            latestState.downloadProgress[widget.videoId.trim()] ??
            0.0;

        return _buildTileContent(
          isDownloaded: currentIsDownloaded,
          isDownloading: currentIsDownloading,
          progress: currentProgress,
        );
      },
    );
  }

  Widget _buildTileContent({
    required bool isDownloaded,
    required bool isDownloading,
    required double progress,
  }) {
    // Si está descargando, mostrar progreso
    if (isDownloading) {
      return ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: progress > 0 ? progress : null,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.iconColor ?? AppColorsDark.primary,
            ),
          ),
        ),
        title: Text(
          'Descargando... ${(progress * 100).toInt()}%',
          style: const TextStyle(color: Colors.white),
        ),
        onTap: () {
          _cubit?.removeDownload(widget.videoId);
        },
      );
    }

    // Si está descargado, mostrar opción de eliminar o reproducir offline
    if (isDownloaded) {
      return ListTile(
        leading: const Icon(
          Icons.download_done,
          color:
              Colors.purple, // Color morado para indicar que ya está descargado
        ),
        title: Text(
          widget.label,
          style: const TextStyle(color: Colors.purple), // Color morado
        ),
        subtitle: const Text(
          'Disponible offline',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        onTap: () {
          _showDownloadedOptions();
        },
      );
    }

    // No descargado - iniciar descarga
    if (_isLoadingStreamUrl) {
      return const ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text(
          'Obteniendo URL de descarga...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListTile(
      leading: Icon(widget.icon, color: widget.iconColor ?? Colors.white70),
      title: Text(widget.label, style: const TextStyle(color: Colors.white)),
      onTap: _startDownload,
    );
  }

  Future<void> _startDownload() async {
    String? streamUrl = _streamUrl;

    if (streamUrl == null || streamUrl.isEmpty) {
      streamUrl = await _getStreamUrl();
    }

    if (streamUrl == null || streamUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la URL de descarga'),
          ),
        );
      }
      return;
    }

    await _cubit?.downloadSong(
      videoId: widget.videoId,
      title: widget.title,
      artist: widget.artist,
      thumbnail: widget.thumbnail,
      streamUrl: streamUrl,
      duration: Duration(seconds: widget.durationSeconds ?? 0),
    );
  }

  void _showDownloadedOptions() {
    if (_cubit == null) return;

    BottomSheetVisibility().showBottomSheet(
      context: context,
      builder: (bottomSheetContext) => Container(
        padding: EdgeInsets.only(
          top: 16,
          bottom: MediaQuery.of(bottomSheetContext).padding.bottom + 80,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.play_circle_outline,
                color: Colors.white,
              ),
              title: const Text(
                'Reproducir offline',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(bottomSheetContext);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.shade300),
              title: Text(
                'Eliminar descarga',
                style: TextStyle(color: Colors.red.shade300),
              ),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _cubit?.removeDownload(widget.videoId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
