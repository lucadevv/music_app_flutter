import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/features/player/domain/repositories/player_repository.dart';

/// Use case for managing playback history lifecycle
///
/// Handles:
/// - Starting new history entries
/// - Updating played duration (throttled)
/// - Finalizing current entry when track changes
class ManageHistoryUseCase {
  final PlayerRepository _repository;

  String? _currentHistoryId;
  int _lastSavedPosition = 0;
  static const int _updateIntervalSeconds = 5;

  ManageHistoryUseCase(this._repository);

  /// Start a new history entry for the given song
  ///
  /// Returns the history ID created
  Future<String?> startNewEntry(Song song) async {
    await finalizeCurrent();

    // Create history entry via repository
    await _repository.addToHistory(song);

    // The repository would need to return the ID - for now, we track locally
    _currentHistoryId =
        '${song.videoId}_${DateTime.now().millisecondsSinceEpoch}';
    _lastSavedPosition = 0;

    return _currentHistoryId;
  }

  /// Update played duration (throttled to avoid excessive writes)
  ///
  /// Only saves when position has changed by [_updateIntervalSeconds]
  Future<void> updatePlayedDuration(int positionSeconds) async {
    if (_currentHistoryId == null) return;

    // Throttle: only save every N seconds
    if (positionSeconds - _lastSavedPosition < _updateIntervalSeconds) {
      return;
    }

    _lastSavedPosition = positionSeconds;
    await _repository.updateHistoryPlayedDuration(
      _currentHistoryId!,
      positionSeconds,
    );
  }

  /// Finalize current history entry
  ///
  /// Should be called when track changes or playback stops
  Future<void> finalizeCurrent() async {
    if (_currentHistoryId == null) return;

    await _repository.updateHistoryPlayedDuration(
      _currentHistoryId!,
      _lastSavedPosition,
    );
    _currentHistoryId = null;
    _lastSavedPosition = 0;
  }
}
