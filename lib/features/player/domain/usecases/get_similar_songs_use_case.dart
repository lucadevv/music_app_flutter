import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/features/player/domain/repositories/player_repository.dart';

/// Use case for getting similar/recommended songs
///
/// Retrieves songs similar to the given videoId
class GetSimilarSongsUseCase {
  final PlayerRepository _repository;

  GetSimilarSongsUseCase(this._repository);

  /// Get similar songs
  ///
  /// [videoId] - The video ID to get similar songs for
  /// [limit] - Maximum number of items to return (default 20)
  Future<List<Song>> call(String videoId, {int limit = 20}) async {
    return _repository.getSimilarSongs(videoId, limit: limit);
  }
}
