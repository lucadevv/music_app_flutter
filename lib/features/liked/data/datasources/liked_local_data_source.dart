import 'package:music_app/features/liked/domain/entities/liked_song_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for liked songs caching.
/// Uses SharedPreferences for simple caching.
class LikedLocalDataSource {
  static const String _likedSongsKey = 'liked_songs_cache';
  
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Get cached liked songs
  Future<List<LikedSongEntity>> getCachedLikedSongs() async {
//     final prefs = await _prefs;
    // This is a simplified version - in production you'd want JSON serialization
    return [];
  }

  /// Cache a liked song
  Future<void> cacheLikedSong(LikedSongEntity song) async {
    // Simplified - would need JSON serialization in production
  }

  /// Remove from cache
  Future<void> removeLikedSong(String videoId) async {
    // Simplified - would need JSON serialization in production
  }

  /// Check if song is in cache
  Future<bool> isSongLiked(String videoId) async {
    final prefs = await _prefs;
    final likedList = prefs.getStringList(_likedSongsKey) ?? [];
    return likedList.contains(videoId);
  }
}
