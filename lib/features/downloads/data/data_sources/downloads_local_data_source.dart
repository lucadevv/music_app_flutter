import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/downloads/data/models/downloaded_song_model.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data source local para gestionar las descargas
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Operaciones locales de descargas
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
  static const String _prefsKeyPrefix = 'downloaded_song_';
  static const String _prefsVideoIdsKey = 'downloaded_video_ids';

  final Dio _dio;
  final SharedPreferences _prefs;
  late String _downloadsDir;

  DownloadsLocalDataSourceImpl(this._dio, this._prefs);

  @override
  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _downloadsDir = '${appDir.path}/downloads';
    final dir = Directory(_downloadsDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  @override
  Future<String> downloadFile(
    String url,
    String videoId,
    void Function(double) onProgress,
  ) async {
    final filePath = '$_downloadsDir/$videoId.mp3';

    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          onProgress(received / total);
        }
      },
    );

    return filePath;
  }

  @override
  Future<void> saveDownloadedSong(DownloadedSongModel song) async {
    // Guardar los datos de la canción
    await _prefs.setString(
      '$_prefsKeyPrefix${song.videoId}',
      song.toJson().toString(),
    );

    // Actualizar la lista de videoIds
    final videoIds = _prefs.getStringList(_prefsVideoIdsKey) ?? [];
    if (!videoIds.contains(song.videoId)) {
      videoIds.add(song.videoId);
      await _prefs.setStringList(_prefsVideoIdsKey, videoIds);
    }
  }

  @override
  Future<List<DownloadedSongModel>> getDownloadedSongs() async {
    final videoIds = _prefs.getStringList(_prefsVideoIdsKey) ?? [];
    final songs = <DownloadedSongModel>[];

    for (final videoId in videoIds) {
      final songJson = _prefs.getString('$_prefsKeyPrefix$videoId');
      if (songJson != null) {
        try {
          // Parsear el string del JSON almacenado
          final json = _parseJsonString(songJson);
          songs.add(DownloadedSongModel.fromJson(json));
        } catch (e) {
          // Si hay error parseando, ignorar esta canción
          continue;
        }
      }
    }

    // Ordenar por fecha de descarga (más reciente primero)
    songs.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));

    return songs;
  }

  /// Parsea un string JSON almacenado en SharedPreferences
  Map<String, dynamic> _parseJsonString(String jsonString) {
    // El formato guardado es: {key: value, key2: value2}
    // Necesitamos convertirlo a JSON válido
    final result = <String, dynamic>{};

    // Remover llaves externas
    var content = jsonString.trim();
    if (content.startsWith('{') && content.endsWith('}')) {
      content = content.substring(1, content.length - 1);
    }

    // Parsear pares key-value
    final pairs = content.split(', ');
    for (final pair in pairs) {
      final keyValue = pair.split(': ');
      if (keyValue.length == 2) {
        final key = keyValue[0].trim();
        var value = keyValue[1].trim();

        // Determinar el tipo de valor
        if (value == 'null') {
          result[key] = null;
        } else if (value.startsWith("'") && value.endsWith("'")) {
          result[key] = value.substring(1, value.length - 1);
        } else if (int.tryParse(value) != null) {
          result[key] = int.parse(value);
        } else {
          result[key] = value;
        }
      }
    }

    return result;
  }

  @override
  Future<void> removeDownloadedSong(String videoId) async {
    final songJson = _prefs.getString('$_prefsKeyPrefix$videoId');
    if (songJson != null) {
      try {
        final json = _parseJsonString(songJson);
        final localPath = json['localPath'] as String?;

        // Eliminar el archivo
        if (localPath != null) {
          final file = File(localPath);
          if (await file.exists()) {
            await file.delete();
          }
        }
      } catch (e) {
        // Ignorar errores de parseo
      }
    }

    // Eliminar de SharedPreferences
    await _prefs.remove('$_prefsKeyPrefix$videoId');

    // Actualizar la lista de videoIds
    final videoIds = _prefs.getStringList(_prefsVideoIdsKey) ?? [];
    videoIds.remove(videoId);
    await _prefs.setStringList(_prefsVideoIdsKey, videoIds);
  }

  @override
  Future<bool> isDownloaded(String videoId) async {
    final videoIds = _prefs.getStringList(_prefsVideoIdsKey) ?? [];
    return videoIds.contains(videoId);
  }

  @override
  Future<String?> getLocalPath(String videoId) async {
    final songJson = _prefs.getString('$_prefsKeyPrefix$videoId');
    if (songJson != null) {
      try {
        final json = _parseJsonString(songJson);
        return json['localPath'] as String?;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
