part of 'playlist_dialog_cubit.dart';

/// State for PlaylistDialogCubit
abstract class PlaylistDialogState {
  const PlaylistDialogState();
}

/// Initial state
class PlaylistDialogInitial extends PlaylistDialogState {}

/// Loading playlists
class PlaylistDialogLoading extends PlaylistDialogState {}

/// Playlists loaded successfully
class PlaylistDialogLoaded extends PlaylistDialogState {
  final List<UserPlaylistEntity> playlists;
  final String searchQuery;

  const PlaylistDialogLoaded({required this.playlists, this.searchQuery = ''});

  PlaylistDialogLoaded copyWith({
    List<UserPlaylistEntity>? playlists,
    String? searchQuery,
  }) {
    return PlaylistDialogLoaded(
      playlists: playlists ?? this.playlists,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Error loading playlists
class PlaylistDialogError extends PlaylistDialogState {
  final String message;

  const PlaylistDialogError(this.message);
}

/// Song added to playlist successfully
class PlaylistDialogSongAdded extends PlaylistDialogState {}

/// Playlist created successfully
class PlaylistDialogPlaylistCreated extends PlaylistDialogState {
  final UserPlaylistEntity playlist;

  const PlaylistDialogPlaylistCreated(this.playlist);
}

/// Adding song to playlist in progress
class PlaylistDialogAddingSong extends PlaylistDialogState {
  final List<UserPlaylistEntity> playlists;
  final String searchQuery;

  const PlaylistDialogAddingSong({
    required this.playlists,
    this.searchQuery = '',
  });
}

/// Creating playlist in progress
class PlaylistDialogCreatingPlaylist extends PlaylistDialogState {
  final List<UserPlaylistEntity> playlists;
  final String searchQuery;

  const PlaylistDialogCreatingPlaylist({
    required this.playlists,
    this.searchQuery = '',
  });
}
