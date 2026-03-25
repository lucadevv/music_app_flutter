import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/radio_track_entity.dart';
import '../repositories/radio_repository.dart';

/// Use case para obtener canciones similares/radio
class GetRadioPlaylistUseCase {
  final RadioRepository _repository;

  GetRadioPlaylistUseCase(this._repository);

  /// Ejecuta el use case para obtener la playlist de radio
  Future<Either<AppException, List<RadioTrackEntity>>> call(
    String videoId, {
    int limit = 10,
  }) {
    return _repository.getRadioPlaylist(videoId, limit: limit);
  }
}
