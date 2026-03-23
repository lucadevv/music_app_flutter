import 'package:music_app/features/player/domain/player_engine.dart';

/// Use case for pausing playback
///
/// Delegates to PlayerEngine for actual audio pause
class PauseSongUseCase {
  final PlayerEngine _engine;

  PauseSongUseCase(this._engine);

  /// Pause the current track
  Future<void> call() async {
    await _engine.pause();
  }
}
