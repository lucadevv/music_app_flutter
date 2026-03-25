import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/radio_track_entity.dart';

/// Repository interface para obtener playlists de radio
abstract class RadioRepository {
  /// Obtiene canciones similares/radio para un videoId
  Future<Either<AppException, List<RadioTrackEntity>>> getRadioPlaylist(
    String videoId, {
    int limit = 10,
  });
}
