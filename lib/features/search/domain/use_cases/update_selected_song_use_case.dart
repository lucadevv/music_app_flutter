import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/song.dart';
import '../repositories/search_repository.dart';

/// Caso de uso para actualizar la canción seleccionada en una búsqueda reciente
class UpdateSelectedSongUseCase {
  final SearchRepository _repository;

  UpdateSelectedSongUseCase(this._repository);

  /// Actualiza la canción seleccionada
  /// Se llama cuando el usuario toca una canción de los resultados de búsqueda
  Future<Either<AppException, void>> call({
    required String query,
    required String videoId,
    required Song song,
  }) async {
    return _repository.updateSelectedSong(
      query: query,
      videoId: videoId,
      song: song,
    );
  }
}
