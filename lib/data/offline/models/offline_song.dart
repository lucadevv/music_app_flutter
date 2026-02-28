import 'package:hive/hive.dart';

/// Adaptador manual para OfflineSong
class OfflineSongAdapter extends TypeAdapter<OfflineSong> {
  @override
  final int typeId = 0;

  @override
  OfflineSong read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineSong()
      ..songId = fields[0] as String
      ..videoId = fields[1] as String
      ..title = fields[2] as String
      ..artist = fields[3] as String
      ..thumbnail = fields[4] as String?
      ..duration = fields[5] as int?
      ..localAudioPath = fields[6] as String?
      ..localThumbnailPath = fields[7] as String?
      ..addedAt = fields[8] as DateTime
      ..lastSyncedAt = fields[9] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, OfflineSong obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.songId)
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
      ..write(obj.localAudioPath)
      ..writeByte(7)
      ..write(obj.localThumbnailPath)
      ..writeByte(8)
      ..write(obj.addedAt)
      ..writeByte(9)
      ..write(obj.lastSyncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineSongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Modelo Hive para almacenar canciones favoritas offline
///
/// Proporciona acceso offline a las canciones favoritas del usuario
/// sin necesidad de conexión a internet.
class OfflineSong extends HiveObject {
  /// ID único de la canción en el servidor (UUID del servidor)
  late String songId;

  /// Video ID de YouTube
  late String videoId;

  /// Título de la canción
  late String title;

  /// Nombre del artista
  late String artist;

  /// URL de la miniatura (puede ser null si no está disponible)
  String? thumbnail;

  /// Duración en segundos
  int? duration;

  /// Ruta local del archivo de audio descargado (nullable)
  String? localAudioPath;

  /// Ruta local de la miniatura descargada (nullable)
  String? localThumbnailPath;

  /// Fecha en que se agregó a favoritos
  late DateTime addedAt;

  /// Fecha de la última sincronización con el servidor
  DateTime? lastSyncedAt;

  /// Indica si la canción está disponible offline (tiene audio descargado)
  bool get isAvailableOffline => localAudioPath != null;

  /// Constructor por defecto
  OfflineSong();

  /// Constructor factory para crear desde datos del servidor
  factory OfflineSong.fromServerData({
    required String songId,
    required String videoId,
    required String title,
    required String artist,
    String? thumbnail,
    int? duration,
    required DateTime addedAt,
  }) {
    return OfflineSong()
      ..songId = songId
      ..videoId = videoId
      ..title = title
      ..artist = artist
      ..thumbnail = thumbnail
      ..duration = duration
      ..addedAt = addedAt;
  }

  /// Convierte a JSON para sincronización
  Map<String, dynamic> toJson() => {
        'songId': songId,
        'videoId': videoId,
        'title': title,
        'artist': artist,
        'thumbnail': thumbnail,
        'duration': duration,
        'addedAt': addedAt.toIso8601String(),
      };
}
