import '../repositories/stream_url_repository.dart';

/// Use case para obtener la URL de streaming de una canción
class GetStreamUrlUseCase {
  final StreamUrlRepository _repository;

  GetStreamUrlUseCase(this._repository);

  /// Ejecuta el use case para obtener la stream URL
  /// [bypassCache] - Si true, ignora la caché y obtiene URL fresca
  Future<String?> call(String videoId, {bool bypassCache = false}) {
    return _repository.getStreamUrl(videoId, bypassCache: bypassCache);
  }
}
