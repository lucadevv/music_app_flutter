import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/features/player/domain/repositories/player_repository.dart';

/// Use case for retrieving playback history
///
/// Gets recently played songs from the repository
class GetHistoryUseCase {
  final PlayerRepository _repository;

  GetHistoryUseCase(this._repository);

  /// Get playback history
  ///
  /// [limit] - Maximum number of items to return (default 50)
  Future<List<Song>> call({int limit = 50}) async {
    return _repository.getHistory(limit: limit);
  }
}
