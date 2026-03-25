import 'package:music_app/core/data/offline/services/offline_service.dart';
import 'package:music_app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:music_app/features/song_options/domain/entities/song_option_entity.dart';

/// Data source for song options.
/// Uses LibraryRemoteDataSource for API calls following Clean Architecture.
class SongOptionsDataSource {
  final LibraryRemoteDataSource _remoteDataSource;
  final OfflineService _offlineService;

  SongOptionsDataSource(this._remoteDataSource, this._offlineService);

  /// Get song options
  Future<SongOptionEntity> getSongOptions(String videoId) async {
    final isFavorite = await _remoteDataSource.isSongFavorite(videoId);
    final isDownloaded = await _offlineService.isSongDownloaded(videoId);

    return SongOptionEntity(
      videoId: videoId,
      title: '',
      artist: '',
      isFavorite: isFavorite,
      isDownloaded: isDownloaded,
    );
  }

  /// Toggle favorite - passes full metadata
  Future<void> toggleFavorite(SongOptionEntity song) async {
    if (song.isFavorite) {
      await _remoteDataSource.removeFavoriteSong(song.videoId);
    } else {
      await _remoteDataSource.addFavoriteSong(
        videoId: song.videoId,
        title: song.title,
        artist: song.artist,
        thumbnail: song.thumbnail,
        duration: song.durationSeconds,
      );
    }
  }

  /// Download song - requires streamUrl
  Future<void> downloadSong(
    String videoId,
    String title,
    String artist,
    String? thumbnail,
    String streamUrl,
  ) async {
    await _offlineService.downloadSongAudio(videoId, streamUrl);
  }

  /// Remove download
  Future<void> removeDownload(String videoId) async {
    await _offlineService.deleteOfflineSong(videoId);
  }
}
