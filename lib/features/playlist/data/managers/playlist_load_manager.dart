import 'dart:async';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

/// Progreso de carga de playlist
class PlaylistLoadProgress {
  final int loaded;
  final int total;
  final bool isFirst; // Indica si es la primera canción

  PlaylistLoadProgress({
    required this.loaded,
    required this.total,
    this.isFirst = false,
  });
}

/// Manager para cargar playlists sin bloquear la UI
/// 
/// Flujo:
/// 1. Cargar primera canción
/// 2. Reproducir primera
/// 3. Esperar confirmación de reproducción
/// 4. Cargar resto
class PlaylistLoadManager {
  final void Function(NowPlayingData track, bool isFirst)? onTrackLoaded;
  final void Function(PlaylistLoadProgress progress)? onProgress;

  bool _isCancelled = false;
  bool _isRunning = false;
  int _totalTracks = 0;
  bool _remainingStarted = false;

  PlaylistLoadManager({
    this.onTrackLoaded,
    this.onProgress,
  });

  /// Cancela la carga
  void cancel() {
    _isCancelled = true;
  }

  /// Carga la primera canción y espera. 
  /// El caller debe indicar cuando empezar a cargar el resto con startRemaining()
  /// 
  /// [tracks] - Lista de tracks a cargar
  /// [getStreamUrl] - Función para obtener URL de streaming
  Future<NowPlayingData?> loadFirst({
    required List<NowPlayingData> tracks,
    required Future<String?> Function(String videoId) getStreamUrl,
  }) async {
    if (_isRunning || tracks.isEmpty) return null;
    _isRunning = true;
    _isCancelled = false;
    _remainingStarted = false;

    final total = tracks.length;
    _totalTracks = total;

    try {
      // Cargar primera canción con retry
      NowPlayingData? firstTrackWithUrl;
      
      for (int i = 0; i < total && firstTrackWithUrl == null && !_isCancelled; i++) {
        final track = tracks[i];
        
        String? streamUrl;
        for (int retry = 0; retry < 3 && (streamUrl == null || streamUrl.isEmpty) && !_isCancelled; retry++) {
          if (retry > 0) {
            await Future.delayed(const Duration(seconds: 2));
          }
          streamUrl = await getStreamUrl(track.videoId);
        }
        
        if (streamUrl != null && streamUrl.isNotEmpty) {
          firstTrackWithUrl = _copyWithStreamUrl(track, streamUrl);
        }
        
        // Delay entre canciones si falló
        if (firstTrackWithUrl == null && i < total - 1) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      if (firstTrackWithUrl == null || _isCancelled) {
        onProgress?.call(PlaylistLoadProgress(loaded: 0, total: total, isFirst: true));
        _isRunning = false;
        return null;
      }

      // Enviar primera al player
      onTrackLoaded?.call(firstTrackWithUrl, true);
      onProgress?.call(PlaylistLoadProgress(loaded: 1, total: total, isFirst: true));

      return firstTrackWithUrl;
    } catch (e) {
      _isRunning = false;
      return null;
    }
  }

  /// Inicia la carga del resto de canciones
  /// Debe llamarse DESPUÉS de que la primera esté reproduciendo
  Future<void> startRemaining({
    required List<NowPlayingData> tracks,
    required Future<String?> Function(String videoId) getStreamUrl,
    required NowPlayingData firstTrack,
  }) async {
    if (_remainingStarted) return;
    _remainingStarted = true;

    final remainingTracks = tracks.where((t) => t.videoId != firstTrack.videoId).toList();
    
    if (remainingTracks.isEmpty || _isCancelled) {
      _isRunning = false;
      return;
    }

    // Cargar resto secuencial
    int loaded = 1;

    for (int i = 0; i < remainingTracks.length && !_isCancelled; i++) {
      if (i > 0) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
      
      final track = remainingTracks[i];
      final url = await getStreamUrl(track.videoId);
      
      if (url != null && url.isNotEmpty) {
        final trackWithUrl = _copyWithStreamUrl(track, url);
        onTrackLoaded?.call(trackWithUrl, false);
        loaded++;
        onProgress?.call(PlaylistLoadProgress(loaded: loaded, total: _totalTracks));
      }
    }

    // Carga completa
    onProgress?.call(PlaylistLoadProgress(loaded: _totalTracks, total: _totalTracks, isFirst: false));
    _isRunning = false;
  }

  /// Copia el track con la streamUrl
  NowPlayingData _copyWithStreamUrl(NowPlayingData track, String streamUrl) {
    return NowPlayingData(
      videoId: track.videoId,
      title: track.title,
      artists: track.artists,
      album: track.album,
      duration: track.duration,
      durationSeconds: track.durationSeconds,
      views: track.views,
      isExplicit: track.isExplicit,
      inLibrary: track.inLibrary,
      thumbnails: track.thumbnails,
      streamUrl: streamUrl,
      thumbnail: track.thumbnail,
    );
  }
}
