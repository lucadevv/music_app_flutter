import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/liked/data/datasources/liked_local_data_source.dart';
import 'package:music_app/features/liked/domain/entities/liked_song_entity.dart';

/// Data source for liked songs.
/// Reuses LibraryService for API calls.
class LikedDataSource {
  final LibraryService _libraryService;
  final LikedLocalDataSource _localDataSource;

  LikedDataSource(this._libraryService, this._localDataSource);

  /// Get all liked songs from API
  Future<List<LikedSongEntity>> getLikedSongs({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _libraryService.getFavoriteSongs(
      page: page,
      limit: limit,
    );
    
    return response.data.map((song) => LikedSongEntity(
      videoId: song.videoId,
      title: song.title,
      artist: song.artist,
      thumbnail: song.thumbnail,
      duration: song.duration,
      addedAt: song.createdAt,
    )).toList();
  }

  /// Add song to liked (API + local cache)
  Future<void> addLikedSong(LikedSongEntity song) async {
    await _libraryService.addFavoriteSong(
      song.videoId,
      title: song.title,
      artist: song.artist,
      thumbnail: song.thumbnail,
      duration: song.duration,
    );
    // Also save to local cache
    await _localDataSource.cacheLikedSong(song);
  }

  /// Remove song from liked
  Future<void> removeLikedSong(String videoId) async {
    await _libraryService.removeFavoriteSong(videoId);
    await _localDataSource.removeLikedSong(videoId);
  }

  /// Check if song is liked
  Future<bool> isSongLiked(String videoId) async {
    // Check local cache first
    final isCached = await _localDataSource.isSongLiked(videoId);
    if (isCached) return true;
    
    // Check API
    return _libraryService.isSongFavorite(videoId);
  }
}
