/// Repository interface para obtener stream URL de una canción
abstract class StreamUrlRepository {
  /// Obtiene la URL de streaming para un videoId
  /// [bypassCache] - Si true, ignora la caché y obtiene URL fresca
  Future<String?> getStreamUrl(String videoId, {bool bypassCache = false});
}
