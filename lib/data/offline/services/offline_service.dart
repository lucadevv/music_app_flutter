import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_app/data/offline/models/offline_history.dart';
import 'package:music_app/data/offline/models/offline_playlist.dart';
import 'package:music_app/data/offline/models/offline_song.dart';
import 'package:music_app/data/offline/services/audio_download_service.dart';
import 'package:path_provider/path_provider.dart';

/// Constantes para los nombres de las cajas de Hive
class HiveBoxes {
  static const String songsBox = 'offline_songs';
  static const String playlistsBox = 'offline_playlists';
  static const String historyBox = 'offline_history';
  static const String queueBox = 'offline_queue';
  static const String queueStateBox = 'offline_queue_state';
}

/// Servicio para gestionar el almacenamiento offline con Hive
///
/// Proporciona métodos para sincronizar datos con el servidor,
/// descargar audio y acceder a todo sin conexión a internet.
class OfflineService {
  late Box<OfflineSong> _songsBox;
  late Box<OfflinePlaylist> _playlistsBox;
  late Box<OfflineHistory> _historyBox;

  final Dio _dio;
  final Connectivity _connectivity;
  late AudioDownloadService _downloadService;

  bool _isInitialized = false;

  OfflineService(this._dio, this._connectivity) {
    _downloadService = AudioDownloadService(_dio);
  }

  /// Indica si el servicio está inicializado
  bool get isInitialized => _isInitialized;

  /// Servicio de descarga de audio
  AudioDownloadService get downloadService => _downloadService;

  /// Indica si hay conexión a internet
  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Inicializa Hive, abre las cajas y el servicio de descarga
  Future<void> init() async {
    if (_isInitialized) return;

    // Inicializar Hive
    await Hive.initFlutter();

    // Registrar adaptadores
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfflineSongAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(OfflinePlaylistAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(OfflineHistoryAdapter());
    }

    // Abrir cajas
    _songsBox = await Hive.openBox<OfflineSong>(HiveBoxes.songsBox);
    _playlistsBox = await Hive.openBox<OfflinePlaylist>(HiveBoxes.playlistsBox);
    _historyBox = await Hive.openBox<OfflineHistory>(HiveBoxes.historyBox);

    // Inicializar servicio de descarga
    await _downloadService.init();

    _isInitialized = true;
  }

  /// Cierra las cajas de Hive y libera recursos
  Future<void> close() async {
    await _songsBox.close();
    await _playlistsBox.close();
    await _historyBox.close();
    _downloadService.dispose();
    _isInitialized = false;
  }

  // ==================== Songs (Favorites) ====================

  /// Obtiene todas las canciones favoritas guardadas offline
  Future<List<OfflineSong>> getOfflineSongs() async {
    return _songsBox.values.toList();
  }

  /// Obtiene una canción por su videoId
  OfflineSong? getSongByVideoId(String videoId) {
    try {
      return _songsBox.values.firstWhere((song) => song.videoId == videoId);
    } catch (e) {
      return null;
    }
  }

  /// Guarda una canción favorita offline
  Future<void> saveOfflineSong(OfflineSong song) async {
    await _songsBox.put(song.videoId, song);
  }

  /// Elimina una canción de favoritos offline (y su archivo de audio)
  Future<void> deleteOfflineSong(String videoId) async {
    // Eliminar archivo de audio si existe
    await _downloadService.deleteSong(videoId);
    // Eliminar de la base de datos
    await _songsBox.delete(videoId);
  }

  /// Busca canciones por título o artista
  Future<List<OfflineSong>> searchSongs(String query) async {
    final lowerQuery = query.toLowerCase();
    return _songsBox.values
        .where(
          (song) =>
              song.title.toLowerCase().contains(lowerQuery) ||
              song.artist.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Obtiene el número de canciones disponibles offline
  Future<int> getOfflineSongsCount() async {
    return _songsBox.length;
  }

  /// Obtiene el número de playlists guardadas offline
  Future<int> getOfflinePlaylistsCount() async {
    return _playlistsBox.length;
  }

  /// Obtiene el número de canciones descargadas (archivos .mp3)
  Future<int> getDownloadedSongsCount() async {
    return _downloadService.getDownloadedCount();
  }

  // ==================== Downloads ====================

  /// Descarga el audio de una canción para uso offline
  Future<String?> downloadSongAudio(
    String videoId,
    String streamUrl, {
    void Function(DownloadProgress)? onProgress,
  }) async {
    final localPath = await _downloadService.downloadSong(
      videoId: videoId,
      streamUrl: streamUrl,
      onProgress: onProgress,
    );

    if (localPath != null) {
      // Actualizar la canción en la base de datos con la ruta local
      final song = getSongByVideoId(videoId);
      if (song != null) {
        song.localAudioPath = localPath;
        await song.save();
      }
    }

    return localPath;
  }

  /// Cancela una descarga en progreso
  void cancelDownload(String videoId) {
    _downloadService.cancelDownload(videoId);
  }

  /// Obtiene el progreso de una descarga
  DownloadProgress? getDownloadProgress(String videoId) {
    return _downloadService.getProgress(videoId);
  }

  /// Stream de progreso de descargas
  Stream<DownloadProgress> get downloadProgressStream =>
      _downloadService.progressStream;

  /// Verifica si una canción tiene audio descargado
  Future<bool> isSongDownloaded(String videoId) async {
    final song = getSongByVideoId(videoId);
    if (song?.localAudioPath != null) {
      final file = File(song!.localAudioPath!);
      return file.exists();
    }
    return _downloadService.isDownloaded(videoId);
  }

  /// Obtiene la ruta local del audio de una canción
  Future<String?> getLocalAudioPath(String videoId) async {
    final song = getSongByVideoId(videoId);
    if (song?.localAudioPath != null) {
      final file = File(song!.localAudioPath!);
      if (await file.exists()) {
        return song.localAudioPath;
      }
    }
    return _downloadService.getLocalPath(videoId);
  }

  /// Obtiene el tamaño total de las descargas
  Future<int> getTotalDownloadsSize() async {
    return _downloadService.getTotalDownloadsSize();
  }

  /// Obtiene estadísticas de almacenamiento
  Future<StorageStats> getStorageStats() async {
    final totalSize = await _downloadService.getTotalDownloadsSize();
    final downloadedCount = await _downloadService.getDownloadedCount();
    final totalSongs = _songsBox.length;

    return StorageStats(
      totalSongs: totalSongs,
      downloadedSongs: downloadedCount,
      totalSizeBytes: totalSize,
    );
  }

  // ==================== Playlists ====================

  /// Obtiene todas las playlists guardadas offline
  Future<List<OfflinePlaylist>> getOfflinePlaylists() async {
    return _playlistsBox.values.toList();
  }

  /// Obtiene una playlist por su ID
  OfflinePlaylist? getPlaylistById(String playlistId) {
    try {
      return _playlistsBox.values.firstWhere(
        (playlist) => playlist.playlistId == playlistId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Guarda una playlist offline
  Future<void> saveOfflinePlaylist(OfflinePlaylist playlist) async {
    await _playlistsBox.put(playlist.playlistId, playlist);
  }

  /// Elimina una playlist de favoritos offline
  Future<void> deleteOfflinePlaylist(String playlistId) async {
    await _playlistsBox.delete(playlistId);
  }

  // ==================== History ====================

  /// Obtiene el historial de reproducción
  Future<List<OfflineHistory>> getHistory({int limit = 50}) async {
    final allHistory = _historyBox.values.toList();
    // Ordenar por fecha descendente
    allHistory.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return allHistory.take(limit).toList();
  }

  /// Agrega una entrada al historial
  Future<void> addToHistory(OfflineHistory history) async {
    await _historyBox.put(history.historyId, history);
  }

  /// Actualiza la duración reproducida de una entrada del historial
  Future<void> updateHistoryPlayedDuration(
    String historyId,
    int playedDuration,
  ) async {
    final history = _historyBox.get(historyId);
    if (history != null) {
      history.updatePlayedDuration(playedDuration);
      await history.save();
    }
  }

  /// Limpia el historial de reproducción
  Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  /// Obtiene estadísticas de reproducción
  Future<HistoryStats> getHistoryStats() async {
    final allHistory = _historyBox.values.toList();

    final int totalPlayed = allHistory.length;
    final int totalCompleted = allHistory.where((h) => h.isCompleted).length;
    final int totalDuration = allHistory.fold(
      0,
      (sum, h) => sum + h.playedDuration,
    );

    // Artistas más escuchados
    final artistCounts = <String, int>{};
    for (final history in allHistory) {
      artistCounts[history.artist] = (artistCounts[history.artist] ?? 0) + 1;
    }
    final topArtists = artistCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return HistoryStats(
      totalPlayed: totalPlayed,
      totalCompleted: totalCompleted,
      totalDurationSeconds: totalDuration,
      topArtists: topArtists.take(5).map((e) => e.key).toList(),
    );
  }

  // ==================== Sincronización ====================

  /// Sincroniza las canciones favoritas con el servidor
  /// Retorna el número de canciones sincronizadas
  Future<int> syncFavoriteSongs(List<Map<String, dynamic>> serverSongs) async {
    int synced = 0;
    for (final songData in serverSongs) {
      final song = songData['song'] as Map<String, dynamic>;
      final offlineSong = OfflineSong()
        ..songId = song['id'] ?? ''
        ..videoId = song['videoId'] ?? ''
        ..title = song['title'] ?? ''
        ..artist = song['artist'] ?? ''
        ..thumbnail = song['thumbnail']
        ..duration = song['duration']
        ..addedAt =
            DateTime.tryParse(songData['createdAt'] ?? '') ?? DateTime.now()
        ..lastSyncedAt = DateTime.now();

      // Mantener la ruta de audio local si existe
      final existing = getSongByVideoId(offlineSong.videoId);
      if (existing != null) {
        offlineSong.localAudioPath = existing.localAudioPath;
        offlineSong.localThumbnailPath = existing.localThumbnailPath;
      }

      await saveOfflineSong(offlineSong);
      synced++;
    }
    return synced;
  }

  /// Sincroniza las playlists con el servidor
  Future<int> syncPlaylists(List<Map<String, dynamic>> serverPlaylists) async {
    int synced = 0;
    for (final playlistData in serverPlaylists) {
      final playlist = playlistData['playlist'] as Map<String, dynamic>;
      final videoIds =
          (playlist['songs'] as List?)
              ?.map((s) => s['videoId'] as String)
              .toList() ??
          [];

      final offlinePlaylist = OfflinePlaylist()
        ..playlistId = playlist['id'] ?? ''
        ..externalPlaylistId = playlist['externalPlaylistId'] ?? ''
        ..name = playlist['name'] ?? ''
        ..description = playlist['description']
        ..thumbnail = playlist['thumbnail']
        ..videoIds = videoIds
        ..trackCount = videoIds.length
        ..createdAt =
            DateTime.tryParse(playlistData['createdAt'] ?? '') ?? DateTime.now()
        ..lastSyncedAt = DateTime.now();

      // Mantener la ruta de miniatura local si existe
      final existing = getPlaylistById(offlinePlaylist.playlistId);
      if (existing != null) {
        offlinePlaylist.localThumbnailPath = existing.localThumbnailPath;
      }

      await saveOfflinePlaylist(offlinePlaylist);
      synced++;
    }
    return synced;
  }

  /// Descarga una miniatura y la guarda localmente
  Future<String?> downloadThumbnail(String url, String videoId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final thumbnailDir = Directory('${dir.path}/thumbnails');
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }

      final filePath = '${thumbnailDir.path}/$videoId.jpg';
      await _dio.download(url, filePath);
      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Limpia datos de sincronización antiguos
  Future<void> cleanOldSyncData() async {
    final threshold = DateTime.now().subtract(const Duration(days: 30));
    final keysToDelete = <String>[];

    for (final history in _historyBox.values) {
      if (history.playedAt.isBefore(threshold)) {
        keysToDelete.add(history.historyId);
      }
    }

    await _historyBox.deleteAll(keysToDelete);
  }
}

/// Estadísticas del historial de reproducción
class HistoryStats {
  final int totalPlayed;
  final int totalCompleted;
  final int totalDurationSeconds;
  final List<String> topArtists;

  HistoryStats({
    required this.totalPlayed,
    required this.totalCompleted,
    required this.totalDurationSeconds,
    required this.topArtists,
  });

  /// Duración total formateada
  String get totalDurationFormatted {
    final hours = totalDurationSeconds ~/ 3600;
    final minutes = (totalDurationSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// Estadísticas de almacenamiento
class StorageStats {
  final int totalSongs;
  final int downloadedSongs;
  final int totalSizeBytes;

  StorageStats({
    required this.totalSongs,
    required this.downloadedSongs,
    required this.totalSizeBytes,
  });

  /// Tamaño total formateado
  String get totalSizeFormatted {
    if (totalSizeBytes < 1024) {
      return '$totalSizeBytes B';
    } else if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (totalSizeBytes < 1024 * 1024 * 1024) {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Porcentaje de canciones descargadas
  double get downloadPercentage {
    if (totalSongs == 0) return 0.0;
    return downloadedSongs / totalSongs;
  }
}
