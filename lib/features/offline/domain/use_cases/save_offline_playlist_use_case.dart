import 'package:music_app/core/data/offline/models/offline_playlist.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';

class SaveOfflinePlaylistUseCase {
  final OfflineService _offlineService;

  SaveOfflinePlaylistUseCase(this._offlineService);

  Future<void> call(OfflinePlaylist playlist) {
    return _offlineService.saveOfflinePlaylist(playlist);
  }
}
