import 'dart:io';

import 'package:music_app/data/offline/models/offline_song.dart';
import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/downloads/data/models/downloaded_song_model.dart';

/// Data source local para gestionar las descargas
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Operaciones locales de descargas
/// 
/// Delega todas las operaciones a OfflineService (Hive) para
/// persistencia de datos y gestión de descargas.
abstract class DownloadsLocalDataSource {
  /// Inicializa el data source
  Future<void> init();

  /// Guarda una canción descargada en el almacenamiento local
  Future<void> saveDownloadedSong(DownloadedSongModel song);

  /// Obtiene todas las canciones descargadas
  Future<List<DownloadedSongModel>> getDownloadedSongs();

  /// Elimina una canción descargada
  Future<void> removeDownloadedSong(String videoId);

  /// Verifica si una canción está descargada
  Future<bool> isDownloaded(String videoId);

  /// Obtiene la ruta local de una canción descargada
  Future<String?> getLocalPath(String videoId);

  /// Descarga un archivo desde una URL
  Future<String> downloadFile(
    String url,
    String videoId,
    void Function(double) onProgress,
  );
}

class DownloadsLocalDataSourceImpl implements DownloadsLocalDataSource {
  final OfflineService _offlineService;

  DownloadsLocalDataSourceImpl(this._offlineService);

  @override
  Future<void> init() async {
    // OfflineService ya debería estar inicializado por GetIt
    // pero nos aseguramos de que esté listo
    if (!_offlineService.isInitialized) {
      await _offlineService.init();
    }
  }

  @override
  Future<String> downloadFile(
    String url,
    String videoId,
    void Function(double) onProgress,
  ) async {
    final result = await _offlineService.downloadSongAudio(
      videoId,
      url,
      onProgress: (progress) => onProgress(progress.progress),
    );

    if (result == null) {
      throw Exception('Failed to download file for videoId: $videoId');
    }

    return result;
  }

  @override
  Future<void> saveDownloadedSong(DownloadedSongModel song) async {
    // Convertir DownloadedSongModel a OfflineSong
    final offlineSong = OfflineSong()
      ..songId = song.videoId // Usamos videoId como songId si no tenemos uno
      ..videoId = song.videoId
      ..title = song.title
      ..artist = song.artist
      ..thumbnail = song.thumbnail
      ..duration = song.duration.inSeconds
      ..localAudioPath = song.localPath
      ..addedAt = song.downloadedAt
      ..lastSyncedAt = DateTime.now();

    await _offlineService.saveOfflineSong(offlineSong);
  }

  @override
  Future<List<DownloadedSongModel>> getDownloadedSongs() async {
    final offlineSongs = await _offlineService.getOfflineSongs();
    
    // Filtrar solo las que tienen audio descargado (localAudioPath no nulo)
    final downloadedSongs = offlineSongs
        .where((song) => song.localAudioPath != null)
        .toList();

    // Convertir OfflineSong a DownloadedSongModel
    final models = <DownloadedSongModel>[];
    for (final offlineSong in downloadedSongs) {
      final model = await _convertToDownloadedSongModel(offlineSong);
      models.add(model);
    }

    // Ordenar por fecha de descarga (más reciente primero)
    models.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));

    return models;
  }

  @override
  Future<void> removeDownloadedSong(String videoId) async {
    await _offlineService.deleteOfflineSong(videoId);
  }

  @override
  Future<bool> isDownloaded(String videoId) async {
    return _offlineService.isSongDownloaded(videoId);
  }

  @override
  Future<String?> getLocalPath(String videoId) async {
    return _offlineService.getLocalAudioPath(videoId);
  }

  /// Convierte un OfflineSong a DownloadedSongModel
  /// Calcula el fileSize del archivo si existe
  Future<DownloadedSongModel> _convertToDownloadedSongModel(
    OfflineSong offlineSong,
  ) async {
    // Calcular el tamaño del archivo
    int fileSize = 0;
    if (offlineSong.localAudioPath != null) {
      final file = File(offlineSong.localAudioPath!);
      if (await file.exists()) {
        fileSize = await file.length();
      }
    }

    return DownloadedSongModel(
      videoId: offlineSong.videoId,
      title: offlineSong.title,
      artist: offlineSong.artist,
      album: null, // OfflineSong no tiene campo album
      thumbnail: offlineSong.thumbnail,
      localPath: offlineSong.localAudioPath ?? '',
      fileSize: fileSize,
      duration: Duration(seconds: offlineSong.duration ?? 0),
      downloadedAt: offlineSong.addedAt,
    );
  }
}
