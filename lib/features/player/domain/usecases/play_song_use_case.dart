import 'package:music_app/features/player/domain/player_engine.dart';

/// Use case for playing a song
///
/// Delegates to PlayerEngine for actual audio playback
/// Follows Clean Architecture: thin wrapper around infrastructure
class PlaySongUseCase {
  final PlayerEngine _engine;

  PlaySongUseCase(this._engine);

  /// Play the current loaded track
  Future<void> call() async {
    await _engine.play();
  }
}
