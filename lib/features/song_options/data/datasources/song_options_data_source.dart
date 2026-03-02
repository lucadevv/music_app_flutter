import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/song_options/domain/entities/song_option_entity.dart';

/// Data source for song options.
/// Combines LibraryService and OfflineService.
class SongOptionsDataSource {
  final LibraryService _libraryService;
  final OfflineService _offlineService;

  SongOptionsDataSource(this._libraryService, this._offlineService);

  /// Get song options
  Future<SongOptionEntity> getSongOptions(String videoId) async {
    final isFavorite = await _libraryService.isSongFavorite(videoId);
    final isDownloaded = await _offlineService.isSongDownloaded(videoId);
    
    return SongOptionEntity(
      videoId: videoId,
      title: '',
      artist: '',
      isFavorite: isFavorite,
      isDownloaded: isDownloaded,
    );
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String videoId, bool isFavorite) async {
    if (isFavorite) {
      await _libraryService.removeFavoriteSong(videoId);
    } else {
      await _libraryService.addFavoriteSong(videoId);
    }
  }

  /// Download song - requires streamUrl
  Future<void> downloadSong(String videoId, String title, String artist, String? thumbnail, String streamUrl) async {
    await _offlineService.downloadSongAudio(videoId, streamUrl);
  }

  /// Remove download
  Future<void> removeDownload(String videoId) async {
    await _offlineService.deleteOfflineSong(videoId);
  }
}
