import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/domain/mappers/song_mapper.dart';
import 'package:music_app/core/data/offline/models/offline_history.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';
import 'package:music_app/features/player/domain/repositories/player_repository.dart';
import 'package:music_app/features/recently_played/domain/repositories/recently_played_repository.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final OfflineService _offlineService;
  final RecentlyPlayedRepository _recentlyPlayedRepository;

  PlayerRepositoryImpl({
    required OfflineService offlineService,
    required RecentlyPlayedRepository recentlyPlayedRepository,
  }) : _offlineService = offlineService,
       _recentlyPlayedRepository = recentlyPlayedRepository;

  @override
  Future<List<Song>> getHistory({int limit = 50}) async {
    final history = await _offlineService.getHistory(limit: limit);
    return history.map((h) => SongMapper.fromOfflineHistory(h)).toList();
  }

  @override
  Future<void> addToHistory(Song song) async {
    final history = _createOfflineHistory(song);
    await _offlineService.addToHistory(history);
  }

  @override
  Future<void> updateHistoryPlayedDuration(
    String historyId,
    int playedDuration,
  ) async {
    await _offlineService.updateHistoryPlayedDuration(
      historyId,
      playedDuration,
    );
  }

  @override
  Future<String?> getLocalAudioPath(String videoId) async {
    if (!_offlineService.isInitialized) return null;
    return _offlineService.getLocalAudioPath(videoId);
  }

  @override
  Future<bool> isSongAvailableOffline(String videoId) async {
    if (!_offlineService.isInitialized) return false;
    return _offlineService.isSongDownloaded(videoId);
  }

  @override
  Future<List<Song>> getSimilarSongs(String videoId, {int limit = 10}) async {
    return [];
  }

  @override
  Future<void> recordListen(String videoId) async {
    await _recentlyPlayedRepository.recordListen(videoId);
  }

  OfflineHistory _createOfflineHistory(Song song) {
    final artistName = song.artist.isNotEmpty ? song.artist : 'Unknown Artist';
    return OfflineHistory.create(
      songId: song.videoId,
      videoId: song.videoId,
      title: song.title,
      artist: artistName,
      thumbnail: song.bestThumbnail,
      duration: song.durationSeconds,
      playedAt: DateTime.now(),
    );
  }
}
