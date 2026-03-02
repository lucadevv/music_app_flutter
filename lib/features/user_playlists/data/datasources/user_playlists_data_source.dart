import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/user_playlists/domain/entities/user_playlist_entity.dart';

/// Data source for user playlists.
/// Reuses LibraryService for API calls.
class UserPlaylistsDataSource {
  final LibraryService _libraryService;

  UserPlaylistsDataSource(this._libraryService);

  /// Get all playlists (user + favorites)
  Future<List<UserPlaylistEntity>> getAllPlaylists() async {
    final userPlaylists = await _libraryService.getUserPlaylists();
    final favoritePlaylists = await _libraryService.getFavoritePlaylists();

    final userPlaylistIds = userPlaylists.data.map((p) => p.id).toSet();

    final uniqueFavorites = favoritePlaylists.data
        .where((p) => !userPlaylistIds.contains(p.playlistId))
        .where((p) => (p.trackCount ?? 0) > 0)
        .toList();

    final all = <UserPlaylistEntity>[
      ...userPlaylists.data.map((p) => UserPlaylistEntity(
            id: p.id,
            name: p.name,
            description: p.description,
            thumbnail: p.thumbnail,
            trackCount: p.songCount,
            isOwner: true,
          )),
      ...uniqueFavorites.map((p) => UserPlaylistEntity(
            id: p.playlistId,
            name: p.name,
            description: p.description,
            thumbnail: p.thumbnail,
            trackCount: p.trackCount ?? 0,
            isOwner: false,
          )),
    ];

    return all;
  }

  /// Get user playlists only
  Future<List<UserPlaylistEntity>> getUserPlaylists() async {
    final response = await _libraryService.getUserPlaylists();
    return response.data
        .map((p) => UserPlaylistEntity(
              id: p.id,
              name: p.name,
              description: p.description,
              thumbnail: p.thumbnail,
              trackCount: p.songCount,
              isOwner: true,
            ))
        .toList();
  }

  /// Create playlist
  Future<UserPlaylistEntity> createPlaylist(String name) async {
    // Would call API to create playlist
    return UserPlaylistEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      trackCount: 0,
      isOwner: true,
    );
  }

  /// Delete playlist
  Future<void> deletePlaylist(String id) async {
    // Would call API to delete playlist
  }
}
