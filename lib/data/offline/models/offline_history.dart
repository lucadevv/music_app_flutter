import 'package:hive/hive.dart';

/// Adaptador manual para OfflineHistory
class OfflineHistoryAdapter extends TypeAdapter<OfflineHistory> {
  @override
  final int typeId = 2;

  @override
  OfflineHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineHistory()
      ..historyId = fields[0] as String
      ..songId = fields[1] as String
      ..videoId = fields[2] as String
      ..title = fields[3] as String
      ..artist = fields[4] as String
      ..thumbnail = fields[5] as String?
      ..duration = fields[6] as int?
      ..playedAt = fields[7] as DateTime
      ..playedDuration = fields[8] as int
      ..playedPercentage = fields[9] as double;
  }

  @override
  void write(BinaryWriter writer, OfflineHistory obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.historyId)
      ..writeByte(1)
      ..write(obj.songId)
      ..writeByte(2)
      ..write(obj.videoId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.artist)
      ..writeByte(5)
      ..write(obj.thumbnail)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.playedAt)
      ..writeByte(8)
      ..write(obj.playedDuration)
      ..writeByte(9)
      ..write(obj.playedPercentage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Modelo Hive para almacenar el historial de reproducción offline
///
/// Mantiene un registro de las canciones reproducidas por el usuario,
/// permitiendo ver el historial incluso sin conexión a internet.
class OfflineHistory extends HiveObject {
  /// ID único del registro de historial
  late String historyId;

  /// ID único de la canción en el servidor
  late String songId;

  /// Video ID de YouTube
  late String videoId;

  /// Título de la canción
  late String title;

  /// Nombre del artista
  late String artist;

  /// URL de la miniatura (nullable)
  String? thumbnail;

  /// Duración en segundos
  int? duration;

  /// Momento en que se reprodujo la canción
  late DateTime playedAt;

  /// Duración total reproducida en segundos
  int playedDuration = 0;

  /// Porcentaje de la canción que se reprodujo (0.0 a 1.0)
  double playedPercentage = 0.0;

  /// Indica si la canción se completó (>= 95% reproducido)
  bool get isCompleted => playedPercentage >= 0.95;

  /// Constructor por defecto
  OfflineHistory();

  /// Constructor factory para crear un nuevo registro de historial
  factory OfflineHistory.create({
    required String songId,
    required String videoId,
    required String title,
    required String artist,
    String? thumbnail,
    int? duration,
    required DateTime playedAt,
    int playedDuration = 0,
  }) {
    return OfflineHistory()
      ..historyId = '${videoId}_${playedAt.millisecondsSinceEpoch}'
      ..songId = songId
      ..videoId = videoId
      ..title = title
      ..artist = artist
      ..thumbnail = thumbnail
      ..duration = duration
      ..playedAt = playedAt
      ..playedDuration = playedDuration
      ..playedPercentage = duration != null && duration > 0
          ? playedDuration / duration
          : 0.0;
  }

  /// Actualiza la duración reproducida
  void updatePlayedDuration(int seconds) {
    playedDuration = seconds;
    if (duration != null && duration! > 0) {
      playedPercentage = seconds / duration!;
    }
  }

  /// Convierte a JSON para sincronización
  Map<String, dynamic> toJson() => {
        'historyId': historyId,
        'songId': songId,
        'videoId': videoId,
        'title': title,
        'artist': artist,
        'thumbnail': thumbnail,
        'duration': duration,
        'playedAt': playedAt.toIso8601String(),
        'playedDuration': playedDuration,
        'playedPercentage': playedPercentage,
      };
}
