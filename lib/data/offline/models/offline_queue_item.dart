import 'package:hive/hive.dart';

/// Adaptador manual para OfflineQueueItem
class OfflineQueueItemAdapter extends TypeAdapter<OfflineQueueItem> {
  @override
  final int typeId = 3;

  @override
  OfflineQueueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineQueueItem(
      queueId: fields[0] as String,
      videoId: fields[1] as String,
      title: fields[2] as String,
      artist: fields[3] as String,
      thumbnail: fields[4] as String?,
      duration: fields[5] as int?,
      position: fields[6] as int,
      localAudioPath: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineQueueItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.queueId)
      ..writeByte(1)
      ..write(obj.videoId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.thumbnail)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.position)
      ..writeByte(7)
      ..write(obj.localAudioPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineQueueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Modelo Hive para almacenar items de la cola de reproducción offline
///
/// Representa una canción en la cola de reproducción con su posición
/// y metadatos necesarios para reproducir sin conexión.
class OfflineQueueItem extends HiveObject {
  /// ID único del item en la cola (UUID)
  late String queueId;

  /// Video ID de YouTube
  late String videoId;

  /// Título de la canción
  late String title;

  /// Nombre del artista
  late String artist;

  /// URL de la miniatura
  String? thumbnail;

  /// Duración en segundos
  int? duration;

  /// Posición en la cola (0 = primera canción)
  late int position;

  /// Ruta local del archivo de audio descargado
  String? localAudioPath;

  /// Constructor con todos los parámetros
  OfflineQueueItem({
    required this.queueId,
    required this.videoId,
    required this.title,
    required this.artist,
    required this.position, this.thumbnail,
    this.duration,
    this.localAudioPath,
  });

  /// Indica si la canción está disponible offline
  bool get isAvailableOffline => localAudioPath != null;

  /// Convierte a JSON
  Map<String, dynamic> toJson() => {
    'queueId': queueId,
    'videoId': videoId,
    'title': title,
    'artist': artist,
    'thumbnail': thumbnail,
    'duration': duration,
    'position': position,
    'localAudioPath': localAudioPath,
  };

  /// Crea una copia con campos modificados
  OfflineQueueItem copyWith({
    String? queueId,
    String? videoId,
    String? title,
    String? artist,
    String? thumbnail,
    int? duration,
    int? position,
    String? localAudioPath,
  }) {
    return OfflineQueueItem(
      queueId: queueId ?? this.queueId,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      localAudioPath: localAudioPath ?? this.localAudioPath,
    );
  }
}

/// Estado completo de la cola de reproducción
///
/// Almacena el estado del reproductor para restaurar
/// la sesión de reproducción cuando la app se reabre.
class OfflineQueueState {
  /// Índice de la canción actual en la cola
  final int currentIndex;

  /// Posición de reproducción en segundos
  final int positionSeconds;

  /// Modo shuffle activado
  final bool shuffleMode;

  /// Modo repeat (0: off, 1: all, 2: one)
  final int repeatMode;

  /// Lista de videoIds en la cola
  final List<String> items;

  /// Fecha de guardado
  final DateTime savedAt;

  OfflineQueueState({
    required this.currentIndex,
    required this.positionSeconds,
    required this.shuffleMode,
    required this.repeatMode,
    required this.items,
    required this.savedAt,
  });

  /// Crea un estado vacío por defecto
  factory OfflineQueueState.empty() {
    return OfflineQueueState(
      currentIndex: 0,
      positionSeconds: 0,
      shuffleMode: false,
      repeatMode: 0,
      items: [],
      savedAt: DateTime.now(),
    );
  }

  /// Convierte a JSON para almacenamiento
  Map<String, dynamic> toJson() => {
    'currentIndex': currentIndex,
    'positionSeconds': positionSeconds,
    'shuffleMode': shuffleMode,
    'repeatMode': repeatMode,
    'items': items,
    'savedAt': savedAt.toIso8601String(),
  };

  /// Crea desde JSON
  factory OfflineQueueState.fromJson(Map<String, dynamic> json) {
    return OfflineQueueState(
      currentIndex: json['currentIndex'] as int? ?? 0,
      positionSeconds: json['positionSeconds'] as int? ?? 0,
      shuffleMode: json['shuffleMode'] as bool? ?? false,
      repeatMode: json['repeatMode'] as int? ?? 0,
      items: (json['items'] as List<dynamic>?)?.cast<String>() ?? [],
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Crea una copia con campos modificados
  OfflineQueueState copyWith({
    int? currentIndex,
    int? positionSeconds,
    bool? shuffleMode,
    int? repeatMode,
    List<String>? items,
    DateTime? savedAt,
  }) {
    return OfflineQueueState(
      currentIndex: currentIndex ?? this.currentIndex,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      repeatMode: repeatMode ?? this.repeatMode,
      items: items ?? this.items,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
