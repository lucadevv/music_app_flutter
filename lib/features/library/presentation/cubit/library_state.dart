part of 'library_cubit.dart';

enum LibraryStatus {
  initial,
  loading,
  success,
  failure,
}

/// Represents a playlist item (either user-created or favorite from YouTube)
class PlaylistItem {
  final String id;
  final String? externalPlaylistId;
  final String name;
  final String? description;
  final String? thumbnail;
  final int songCount;
  final bool isUserCreated; // true = user created, false = YouTube favorite

  PlaylistItem({
    required this.id,
    this.externalPlaylistId,
    required this.name,
    this.description,
    this.thumbnail,
    required this.songCount,
    required this.isUserCreated,
  });
}

class LibraryState {
  final LibraryStatus status;
  final String? errorMessage;
  final List<FavoriteSong> favoriteSongs;
  final List<FavoritePlaylist> favoritePlaylists;
  final List<UserPlaylist> userPlaylists;
  final List<PlaylistItem> allPlaylists; // Combinación de playlists del usuario + favoritas
  final List<FavoriteGenre> favoriteGenres;
  final int totalSongs;
  final int totalPlaylists;
  final int totalGenres;
  final LibrarySummary? summary;
  final bool isLoadingMoreSongs;
  final bool isOffline;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.errorMessage,
    this.favoriteSongs = const [],
    this.favoritePlaylists = const [],
    this.userPlaylists = const [],
    this.allPlaylists = const [],
    this.favoriteGenres = const [],
    this.totalSongs = 0,
    this.totalPlaylists = 0,
    this.totalGenres = 0,
    this.summary,
    this.isLoadingMoreSongs = false,
    this.isOffline = false,
  });

  bool get hasMoreSongs => favoriteSongs.length < totalSongs;
  bool get hasMorePlaylists => favoritePlaylists.length < totalPlaylists;
  bool get hasMoreGenres => favoriteGenres.length < totalGenres;
  bool get isEmpty => favoriteSongs.isEmpty && favoritePlaylists.isEmpty && favoriteGenres.isEmpty;

  LibraryState copyWith({
    LibraryStatus? status,
    String? errorMessage,
    List<FavoriteSong>? favoriteSongs,
    List<FavoritePlaylist>? favoritePlaylists,
    List<UserPlaylist>? userPlaylists,
    List<PlaylistItem>? allPlaylists,
    List<FavoriteGenre>? favoriteGenres,
    int? totalSongs,
    int? totalPlaylists,
    int? totalGenres,
    LibrarySummary? summary,
    bool? isLoadingMoreSongs,
    bool? isOffline,
    bool clearError = false,
  }) {
    return LibraryState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      favoriteSongs: favoriteSongs ?? this.favoriteSongs,
      favoritePlaylists: favoritePlaylists ?? this.favoritePlaylists,
      userPlaylists: userPlaylists ?? this.userPlaylists,
      allPlaylists: allPlaylists ?? this.allPlaylists,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      totalSongs: totalSongs ?? this.totalSongs,
      totalPlaylists: totalPlaylists ?? this.totalPlaylists,
      totalGenres: totalGenres ?? this.totalGenres,
      summary: summary ?? this.summary,
      isLoadingMoreSongs: isLoadingMoreSongs ?? this.isLoadingMoreSongs,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
