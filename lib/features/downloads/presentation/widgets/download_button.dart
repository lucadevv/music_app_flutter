import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/downloads/presentation/cubit/downloads_cubit.dart';

/// Widget para descargar canciones
///
/// Muestra el estado de descarga y permite iniciar/cancelar descargas
class DownloadButton extends StatefulWidget {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final String streamUrl;
  final int durationSeconds;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const DownloadButton({
    super.key,
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    required this.streamUrl,
    required this.durationSeconds,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  DownloadsCubit? _downloadsCubit;
  bool _isDownloaded = false;
  bool _isDownloading = false;
  double _progress = 0.0;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _initCubit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _initCubit() async {
    try {
      _downloadsCubit = await GetIt.I.getAsync<DownloadsCubit>();
      _checkDownloadStatus();
      
      // Listen to state changes
      _subscription = _downloadsCubit!.stream.listen((state) {
        if (!mounted) return;
        
        final progress = state.downloadProgress[widget.videoId];
        final isDownloading = state.downloadingIds.contains(widget.videoId);
        final isDownloaded = state.downloadedSongs.any((s) => s.videoId == widget.videoId);

        setState(() {
          _progress = progress ?? 0.0;
          _isDownloading = isDownloading;
          _isDownloaded = isDownloaded;
        });
      });
    } catch (e) {
      // DownloadsCubit not available - hide download button
    }
  }

  Future<void> _checkDownloadStatus() async {
    if (_downloadsCubit == null) return;
    
    final isDownloaded = await _downloadsCubit!.isDownloaded(widget.videoId);
    if (mounted) {
      setState(() {
        _isDownloaded = isDownloaded;
      });
    }
  }

  void _handleTap() {
    if (_downloadsCubit == null) return;

    if (_isDownloaded) {
      // Ya descargado - mostrar opciones o reproducir offline
      _showDownloadedOptions();
    } else if (_isDownloading) {
      // Descargando - cancelar
      _downloadsCubit!.removeDownload(widget.videoId);
      setState(() {
        _isDownloading = false;
        _progress = 0.0;
      });
    } else {
      // Iniciar descarga
      _startDownload();
    }
  }

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
    });

    _downloadsCubit!.downloadSong(
      videoId: widget.videoId,
      title: widget.title,
      artist: widget.artist,
      thumbnail: widget.thumbnail,
      streamUrl: widget.streamUrl,
      duration: Duration(seconds: widget.durationSeconds),
    );
  }

  void _showDownloadedOptions() {
    // TODO: Mostrar opciones como eliminar descarga
  }

  @override
  Widget build(BuildContext context) {
    if (_downloadsCubit == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: widget.size + 8,
        height: widget.size + 8,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress indicator
            if (_isDownloading)
              CircularProgressIndicator(
                value: _progress > 0 ? _progress : null,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.activeColor ?? AppColorsDark.primary,
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            
            // Icon
            Icon(
              _isDownloaded 
                  ? Icons.download_done 
                  : (_isDownloading ? Icons.close : Icons.download_outlined),
              color: _isDownloaded
                  ? (widget.activeColor ?? AppColorsDark.primary)
                  : (widget.inactiveColor ?? Colors.white.withValues(alpha: 0.6)),
              size: widget.size,
            ),
          ],
        ),
      ),
    );
  }
}

/// Versión simple de DownloadButton para usar en listas
class DownloadIconButton extends StatelessWidget {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final String streamUrl;
  final int durationSeconds;

  const DownloadIconButton({
    super.key,
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    required this.streamUrl,
    required this.durationSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return DownloadButton(
      videoId: videoId,
      title: title,
      artist: artist,
      thumbnail: thumbnail,
      streamUrl: streamUrl,
      durationSeconds: durationSeconds,
      size: 22,
    );
  }
}
