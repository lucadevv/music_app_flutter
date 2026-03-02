import 'package:hive/hive.dart';

/// Adaptador manual para OfflinePlaylist
class OfflinePlaylistAdapter extends TypeAdapter<OfflinePlaylist> {
  @override
  final int typeId = 1;

  @override
  OfflinePlaylist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflinePlaylist()
      ..playlistId = fields[0] as String
      ..externalPlaylistId = fields[1] as String
      ..name = fields[2] as String
      ..description = fields[3] as String?
      ..thumbnail = fields[4] as String?
      ..localThumbnailPath = fields[5] as String?
      ..videoIds = (fields[6] as List).cast<String>()
      ..trackCount = fields[7] as int
      ..createdAt = fields[8] as DateTime
      ..lastSyncedAt = fields[9] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, OfflinePlaylist obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.playlistId)
      ..writeByte(1)
      ..write(obj.externalPlaylistId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.thumbnail)
      ..writeByte(5)
      ..write(obj.localThumbnailPath)
      ..writeByte(6)
      ..write(obj.videoIds)
      ..writeByte(7)
      ..write(obj.trackCount)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.lastSyncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflinePlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Modelo Hive para almacenar playlists offline
///
/// Proporciona acceso offline a las playlists guardadas por el usuario
class OfflinePlaylist extends HiveObject {
  /// ID único de la playlist en el servidor (UUID del servidor)
  late String playlistId;

  /// ID externo de YouTube (para playlists de YouTube)
  late String externalPlaylistId;

  /// Nombre de la playlist
  late String name;

  /// Descripción de la playlist (nullable)
  String? description;

  /// URL de la miniatura (nullable)
  String? thumbnail;

  /// Ruta local de la miniatura descargada (nullable)
  String? localThumbnailPath;

  /// Lista de IDs de video de las canciones en la playlist
  late List<String> videoIds;

  /// Número de canciones en la playlist
  late int trackCount;

  /// Fecha en que se agregó a favoritos
  late DateTime createdAt;

  /// Fecha de la última sincronización con el servidor
  DateTime? lastSyncedAt;

  /// Indica si la playlist está completamente disponible offline
  bool get isAvailableOffline => localThumbnailPath != null;

  /// Constructor por defecto
  OfflinePlaylist();

  /// Constructor factory para crear desde datos del servidor
  factory OfflinePlaylist.fromServerData({
    required String playlistId,
    required String externalPlaylistId,
    required String name,
    String? description,
    String? thumbnail,
    required List<String> videoIds,
    required int trackCount,
    required DateTime createdAt,
  }) {
    return OfflinePlaylist()
      ..playlistId = playlistId
      ..externalPlaylistId = externalPlaylistId
      ..name = name
      ..description = description
      ..thumbnail = thumbnail
      ..videoIds = videoIds
      ..trackCount = trackCount
      ..createdAt = createdAt;
  }

  /// Convierte a JSON para sincronización
  Map<String, dynamic> toJson() => {
    'playlistId': playlistId,
    'externalPlaylistId': externalPlaylistId,
    'name': name,
    'description': description,
    'thumbnail': thumbnail,
    'videoIds': videoIds,
    'trackCount': trackCount,
    'createdAt': createdAt.toIso8601String(),
  };
}
