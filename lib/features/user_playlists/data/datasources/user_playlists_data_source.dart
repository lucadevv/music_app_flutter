import 'package:music_app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:music_app/features/user_playlists/domain/entities/user_playlist_entity.dart';

/// Data source for user playlists.
/// Uses LibraryRemoteDataSource for API calls following Clean Architecture.
class UserPlaylistsDataSource {
  final LibraryRemoteDataSource _remoteDataSource;

  UserPlaylistsDataSource(this._remoteDataSource);

  /// Get all playlists (user + favorites)
  Future<List<UserPlaylistEntity>> getAllPlaylists() async {
    final userPlaylists = await _remoteDataSource.getUserPlaylists();
    final favoritePlaylists = await _remoteDataSource.getFavoritePlaylists();

    final userPlaylistIds = userPlaylists.data.map((p) => p.id).toSet();

    final uniqueFavorites = favoritePlaylists.data
        .where((p) => !userPlaylistIds.contains(p.externalPlaylistId))
        .where((p) => (p.trackCount ?? 0) > 0)
        .toList();

    final all = <UserPlaylistEntity>[
      ...userPlaylists.data.map(
        (p) => UserPlaylistEntity(
          id: p.id,
          name: p.name,
          description: p.description,
          thumbnail: p.thumbnail,
          trackCount: p.songCount,
          isOwner: true,
        ),
      ),
      ...uniqueFavorites.map(
        (p) => UserPlaylistEntity(
          id: p.externalPlaylistId,
          name: p.name,
          description: p.description,
          thumbnail: p.thumbnail,
          trackCount: p.trackCount ?? 0,
          isOwner: false,
        ),
      ),
    ];

    return all;
  }

  /// Get user playlists only
  Future<List<UserPlaylistEntity>> getUserPlaylists() async {
    final response = await _remoteDataSource.getUserPlaylists();
    return response.data
        .map(
          (p) => UserPlaylistEntity(
            id: p.id,
            name: p.name,
            description: p.description,
            thumbnail: p.thumbnail,
            trackCount: p.songCount,
            isOwner: true,
          ),
        )
        .toList();
  }

  /// Create playlist
  Future<UserPlaylistEntity> createPlaylist(String name) async {
    final playlist = await _remoteDataSource.createUserPlaylist(name: name);
    return UserPlaylistEntity(
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      thumbnail: playlist.thumbnail,
      trackCount: playlist.songCount,
      isOwner: true,
    );
  }

  /// Delete playlist
  Future<void> deletePlaylist(String id) async {
    await _remoteDataSource.deleteUserPlaylist(id);
  }
}
