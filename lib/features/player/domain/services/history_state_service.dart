import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/features/player/domain/repositories/player_repository.dart';

class HistoryStateService {
  final PlayerRepository _repository;

  String? _currentHistoryId;
  int _lastSavedPosition = 0;
  static const int _updateIntervalSeconds = 5;

  HistoryStateService(this._repository);

  Future<String?> startNewEntry(Song song) async {
    await finalizeCurrent();

    await _repository.addToHistory(song);

    _currentHistoryId =
        '${song.videoId}_${DateTime.now().millisecondsSinceEpoch}';
    _lastSavedPosition = 0;

    return _currentHistoryId;
  }

  Future<void> updatePlayedDuration(int positionSeconds) async {
    if (_currentHistoryId == null) return;

    if (positionSeconds - _lastSavedPosition < _updateIntervalSeconds) {
      return;
    }

    _lastSavedPosition = positionSeconds;
    await _repository.updateHistoryPlayedDuration(
      _currentHistoryId!,
      positionSeconds,
    );
  }

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
