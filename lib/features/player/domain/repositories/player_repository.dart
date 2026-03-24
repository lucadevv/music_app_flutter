import 'package:music_app/core/domain/entities/song.dart';

/// Repository interface for player data operations
///
/// Follows Clean Architecture principles:
/// - Domain layer interface (abstraction)
/// - Implementation in data layer
/// - Used by use cases in domain layer
abstract class PlayerRepository {
  /// Get playback history
  ///
  /// Returns a list of recently played songs
  /// [limit] - Maximum number of items to return (default 50)
  Future<List<Song>> getHistory({int limit = 50});

  /// Add song to history
  ///
  /// Creates a new history entry for the given song
  Future<void> addToHistory(Song song);

  /// Update played duration for current history entry
  ///
  /// [historyId] - The unique ID of the history entry
  /// [playedDuration] - Duration in seconds that has been played
  Future<void> updateHistoryPlayedDuration(
    String historyId,
    int playedDuration,
  );

  /// Get local audio path if downloaded
  ///
  /// Returns the local file path for an offline song, or null if not available
  Future<String?> getLocalAudioPath(String videoId);

  /// Check if song is available offline
  ///
  /// Returns true if the song has been downloaded and is available locally
  Future<bool> isSongAvailableOffline(String videoId);

  /// Get similar songs (recommendations)
  ///
  /// Returns a list of similar songs based on the given videoId
  /// [videoId] - The video ID to get similar songs for
  /// [limit] - Maximum number of items to return (default 20)
  Future<List<Song>> getSimilarSongs(String videoId, {int limit = 10});

  /// Record listen to server
  ///
  /// Sends a listen event to the server for analytics
  Future<void> recordListen(String videoId);
}
