import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Estado de una descarga
enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  cancelled,
  paused,
}

/// Información sobre una descarga en progreso
class DownloadProgress {
  final String videoId;
  final DownloadStatus status;
  final double progress; // 0.0 a 1.0
  final int bytesReceived;
  final int totalBytes;
  final String? error;
  final String? localPath;

  DownloadProgress({
    required this.videoId,
    required this.status,
    this.progress = 0.0,
    this.bytesReceived = 0,
    this.totalBytes = 0,
    this.error,
    this.localPath,
  });

  DownloadProgress copyWith({
    DownloadStatus? status,
    double? progress,
    int? bytesReceived,
    int? totalBytes,
    String? error,
    String? localPath,
  }) {
    return DownloadProgress(
      videoId: videoId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      bytesReceived: bytesReceived ?? this.bytesReceived,
      totalBytes: totalBytes ?? this.totalBytes,
      error: error ?? this.error,
      localPath: localPath ?? this.localPath,
    );
  }

  /// Tamaño formateado en MB
  String get fileSizeFormatted {
    final mb = totalBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Progreso formateado como porcentaje
  String get progressFormatted => '${(progress * 100).toStringAsFixed(0)}%';
}

/// Servicio para descargar archivos de audio
///
/// Gestiona la descarga de canciones para uso offline,
/// reportando progreso y manejando errores.
class AudioDownloadService {
  final Dio _dio;

  late String _downloadsDir;
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, DownloadProgress> _downloadProgress = {};

  /// Stream controller para notificar progreso
  final StreamController<DownloadProgress> _progressController =
      StreamController<DownloadProgress>.broadcast();

  /// Stream de progreso de descargas
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  AudioDownloadService(this._dio);

  /// Inicializa el servicio creando el directorio de descargas
  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _downloadsDir = '${appDir.path}/offline_audio';
    final dir = Directory(_downloadsDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Descarga una canción desde una URL
  ///
  /// [videoId] - ID del video de YouTube
  /// [streamUrl] - URL del stream de audio
  /// [onProgress] - Callback para reportar progreso
  ///
  /// Retorna la ruta local del archivo descargado
  Future<String?> downloadSong({
    required String videoId,
    required String streamUrl,
    void Function(DownloadProgress)? onProgress,
  }) async {
    // Cancelar descarga previa si existe
    cancelDownload(videoId);

    final cancelToken = CancelToken();
    _cancelTokens[videoId] = cancelToken;

    final filePath = '$_downloadsDir/$videoId.mp3';

    // Inicializar progreso
    _downloadProgress[videoId] = DownloadProgress(
      videoId: videoId,
      status: DownloadStatus.downloading,
    );
    _notifyProgress(videoId);

    try {
      await _dio.download(
        streamUrl,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            _downloadProgress[videoId] = DownloadProgress(
              videoId: videoId,
              status: DownloadStatus.downloading,
              progress: progress,
              bytesReceived: received,
              totalBytes: total,
            );
            _notifyProgress(videoId);

            if (onProgress != null) {
              onProgress(_downloadProgress[videoId]!);
            }
          }
        },
      );

      // Descarga completada
      _downloadProgress[videoId] = DownloadProgress(
        videoId: videoId,
        status: DownloadStatus.completed,
        progress: 1.0,
        localPath: filePath,
      );
      _notifyProgress(videoId);

      _cancelTokens.remove(videoId);
      return filePath;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _downloadProgress[videoId] = DownloadProgress(
          videoId: videoId,
          status: DownloadStatus.cancelled,
        );
      } else {
        _downloadProgress[videoId] = DownloadProgress(
          videoId: videoId,
          status: DownloadStatus.failed,
          error: e.message ?? 'Error desconocido',
        );
      }
      _notifyProgress(videoId);
      _cancelTokens.remove(videoId);
      return null;
    } catch (e) {
      _downloadProgress[videoId] = DownloadProgress(
        videoId: videoId,
        status: DownloadStatus.failed,
        error: e.toString(),
      );
      _notifyProgress(videoId);
      _cancelTokens.remove(videoId);
      return null;
    }
  }

  /// Cancela una descarga en progreso
  void cancelDownload(String videoId) {
    final cancelToken = _cancelTokens[videoId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Descarga cancelada por el usuario');
    }
    _cancelTokens.remove(videoId);
    _downloadProgress.remove(videoId);
  }

  /// Pausa una descarga (cancela y marca como pausada)
  void pauseDownload(String videoId) {
    final currentProgress = _downloadProgress[videoId];
    if (currentProgress != null &&
        currentProgress.status == DownloadStatus.downloading) {
      cancelDownload(videoId);
      _downloadProgress[videoId] = currentProgress.copyWith(
        status: DownloadStatus.paused,
      );
      _notifyProgress(videoId);
    }
  }

  /// Obtiene el progreso actual de una descarga
  DownloadProgress? getProgress(String videoId) {
    return _downloadProgress[videoId];
  }

  /// Obtiene todas las descargas en progreso
  List<DownloadProgress> getAllDownloads() {
    return _downloadProgress.values
        .where((p) => p.status == DownloadStatus.downloading)
        .toList();
  }

  /// Verifica si una canción está descargada
  Future<bool> isDownloaded(String videoId) async {
    final filePath = '$_downloadsDir/$videoId.mp3';
    final file = File(filePath);
    return file.exists();
  }

  /// Obtiene la ruta local de una canción descargada
  Future<String?> getLocalPath(String videoId) async {
    final filePath = '$_downloadsDir/$videoId.mp3';
    final file = File(filePath);
    if (await file.exists()) {
      return filePath;
    }
    return null;
  }

  /// Obtiene el tamaño de una canción descargada
  Future<int> getFileSize(String videoId) async {
    final filePath = '$_downloadsDir/$videoId.mp3';
    final file = File(filePath);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  /// Elimina una canción descargada
  Future<bool> deleteSong(String videoId) async {
    final filePath = '$_downloadsDir/$videoId.mp3';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      _downloadProgress.remove(videoId);
      return true;
    }
    return false;
  }

  /// Obtiene el tamaño total de las descargas
  Future<int> getTotalDownloadsSize() async {
    final dir = Directory(_downloadsDir);
    if (!await dir.exists()) {
      return 0;
    }

    int totalSize = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  /// Obtiene el número de canciones descargadas
  Future<int> getDownloadedCount() async {
    final dir = Directory(_downloadsDir);
    if (!await dir.exists()) {
      return 0;
    }

    int count = 0;
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.mp3')) {
        count++;
      }
    }
    return count;
  }

  /// Elimina todas las descargas
  Future<void> deleteAll() async {
    final dir = Directory(_downloadsDir);
    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }
    }
    _downloadProgress.clear();
    _cancelTokens.clear();
  }

  /// Notifica el progreso a través del stream
  void _notifyProgress(String videoId) {
    final progress = _downloadProgress[videoId];
    if (progress != null) {
      _progressController.add(progress);
    }
  }

  /// Libera recursos
  void dispose() {
    // Cancelar todas las descargas
    for (final cancelToken in _cancelTokens.values) {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('Service disposed');
      }
    }
    _cancelTokens.clear();
    _downloadProgress.clear();
    _progressController.close();
  }
}
