import 'package:music_app/core/data/offline/models/offline_playlist.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';

class GetOfflinePlaylistsUseCase {
  final OfflineService _offlineService;

  GetOfflinePlaylistsUseCase(this._offlineService);

  Future<List<OfflinePlaylist>> call() {
    return _offlineService.getOfflinePlaylists();
  }
}
