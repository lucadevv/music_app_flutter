/// Repository interface para obtener stream URL de una canción
abstract class StreamUrlRepository {
  /// Obtiene la URL de streaming para un videoId
  Future<String?> getStreamUrl(String videoId);
}
