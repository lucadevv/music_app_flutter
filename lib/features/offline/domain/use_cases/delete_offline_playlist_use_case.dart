import 'package:music_app/core/data/offline/services/offline_service.dart';

class DeleteOfflinePlaylistUseCase {
  final OfflineService _offlineService;

  DeleteOfflinePlaylistUseCase(this._offlineService);

  Future<void> call(String playlistId) {
    return _offlineService.deleteOfflinePlaylist(playlistId);
  }
}
