import '../repositories/radio_repository.dart';

/// Use case para obtener canciones similares/radio
class GetRadioPlaylistUseCase {
  final RadioRepository _repository;

  GetRadioPlaylistUseCase(this._repository);

  /// Ejecuta el use case para obtener la playlist de radio
  Future<List<Map<String, dynamic>>> call(String videoId, {int limit = 10}) {
    return _repository.getRadioPlaylist(videoId, limit: limit);
  }
}
