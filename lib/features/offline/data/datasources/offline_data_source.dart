import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/offline/domain/entities/offline_song_entity.dart';

/// Data source for offline operations.
/// Wraps the existing OfflineService.
class OfflineDataSource {
  final OfflineService _offlineService;
//   final Connectivity _connectivity;

  OfflineDataSource(this._offlineService,  );

  /// Check if device is online
  Future<bool> isOnline() async {
    return _offlineService.isOnline;
  }

  /// Get all downloaded songs (from Hive box)
  Future<List<OfflineSongEntity>> getDownloadedSongs() async {
    final songs = await _offlineService.getOfflineSongs();
    return songs
        .where((song) => song.localAudioPath != null)
        .map((song) => OfflineSongEntity(
              videoId: song.videoId,
              title: song.title,
              artist: song.artist,
              thumbnail: song.thumbnail,
              localPath: song.localAudioPath,
              duration: song.duration,
              downloadedAt: song.addedAt,
            ))
        .toList();
  }

  /// Download a song
  /// Note: This requires streamUrl which should be obtained separately
  Future<void> downloadSong(OfflineSongEntity song, String streamUrl) async {
    await _offlineService.downloadSongAudio(
      song.videoId,
      streamUrl,
    );
  }

  /// Remove downloaded song
  Future<void> removeDownload(String videoId) async {
    await _offlineService.deleteOfflineSong(videoId);
  }

  /// Get download status
  Future<String> getDownloadStatus(String videoId) async {
    if (await _offlineService.isSongDownloaded(videoId)) {
      return 'downloaded';
    }
    final progress = _offlineService.getDownloadProgress(videoId);
    if (progress != null) {
      return 'downloading';
    }
    return 'not_downloaded';
  }

  /// Sync favorites - requires server songs list
  Future<void> syncFavorites(List<Map<String, dynamic>> serverSongs) async {
    await _offlineService.syncFavoriteSongs(serverSongs);
  }
}
