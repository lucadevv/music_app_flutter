import 'package:music_app/features/player/domain/player_engine.dart';

/// Use case for seeking to a position in the track
///
/// Delegates to PlayerEngine for actual seek operation
class SeekSongUseCase {
  final PlayerEngine _engine;

  SeekSongUseCase(this._engine);

  /// Seek to a specific position in the current track
  ///
  /// [position] - The position to seek to
  Future<void> call(Duration position) async {
    await _engine.seek(position);
  }
}
