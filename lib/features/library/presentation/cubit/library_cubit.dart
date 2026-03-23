import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/core/data/offline/models/offline_playlist.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

part 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> with BaseBlocMixin {
  final LibraryService _libraryService;
  final OfflineService _offlineService;
  final PlayerBlocBloc _playerBloc;

  static const int _pageSize = 10;

  LibraryCubit(this._libraryService, this._offlineService, this._playerBloc)
    : super(const LibraryState());

  Future<void> loadLibrary() async {
    if (state.status == LibraryStatus.loading) return;

    emit(state.copyWith(status: LibraryStatus.loading, clearError: true));

    try {
      final isOnline = await _offlineService.isOnline;

      if (!isOnline) {
        await _loadOfflineLibrary();
        return;
      }

      final songsResponse = await _libraryService.getFavoriteSongs(
        page: 1,
        limit: _pageSize,
      );
      final playlistsResponse = await _libraryService.getFavoritePlaylists(
        page: 1,
        limit: _pageSize,
      );
      final userPlaylistsResponse = await _libraryService.getUserPlaylists(
        page: 1,
        limit: 20,
      );
      final genresResponse = await _libraryService.getFavoriteGenres(
        page: 1,
        limit: _pageSize,
      );
      final summary = await _libraryService.getLibrarySummary();

      final allPlaylists = <PlaylistItem>[];

      for (final userPlaylist in userPlaylistsResponse.data) {
        allPlaylists.add(
          PlaylistItem(
            id: userPlaylist.id,
            name: userPlaylist.name,
            description: userPlaylist.description,
            thumbnail: userPlaylist.thumbnail,
            songCount: userPlaylist.songCount,
            isUserCreated: true,
          ),
        );
      }

      for (final favPlaylist in playlistsResponse.data) {
        allPlaylists.add(
          PlaylistItem(
            id: favPlaylist.playlistId,
            externalPlaylistId: favPlaylist.externalPlaylistId,
            name: favPlaylist.name,
            description: favPlaylist.description,
            thumbnail: favPlaylist.thumbnail,
            songCount:
                favPlaylist.cachedTrackCount ?? favPlaylist.trackCount ?? 0,
            isUserCreated: false,
          ),
        );
      }

      if (isClosed) return;

      emit(
        state.copyWith(
          status: LibraryStatus.success,
          favoriteSongs: songsResponse.data,
          favoritePlaylists: playlistsResponse.data,
          userPlaylists: userPlaylistsResponse.data,
          allPlaylists: allPlaylists,
          favoriteGenres: genresResponse.data,
          totalSongs: songsResponse.total,
          totalPlaylists: userPlaylistsResponse.total + playlistsResponse.total,
          totalGenres: genresResponse.total,
          summary: summary,
          clearError: true,
          isOffline: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LibraryStatus.failure,
          errorMessage: _parseError(e),
        ),
      );
    }
  }

  Future<void> _loadOfflineLibrary() async {
    try {
      final offlinePlaylists = await _offlineService.getOfflinePlaylists();

      final favoritePlaylists = offlinePlaylists
          .map(_convertToFavoritePlaylist)
          .toList();

      if (isClosed) return;

      emit(
        state.copyWith(
          status: LibraryStatus.success,
          favoriteSongs: const [],
          favoritePlaylists: favoritePlaylists,
          favoriteGenres: const [],
          totalSongs: 0,
          totalPlaylists: favoritePlaylists.length,
          totalGenres: 0,
          summary: LibrarySummary(
            favoriteSongs: 0,
            favoritePlaylists: favoritePlaylists.length,
            favoriteGenres: 0,
          ),
          clearError: true,
          isOffline: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LibraryStatus.failure,
          errorMessage: _parseError(e),
          isOffline: true,
        ),
      );
    }
  }

  FavoritePlaylist _convertToFavoritePlaylist(OfflinePlaylist offlinePlaylist) {
    return FavoritePlaylist(
      id: offlinePlaylist.playlistId,
      playlistId: offlinePlaylist.playlistId,
      externalPlaylistId: offlinePlaylist.externalPlaylistId,
      name: offlinePlaylist.name,
      description: offlinePlaylist.description,
      thumbnail:
          offlinePlaylist.thumbnail ?? offlinePlaylist.localThumbnailPath,
      trackCount: offlinePlaylist.trackCount,
      createdAt: offlinePlaylist.createdAt,
    );
  }

  Future<void> loadMoreSongs() async {
    if (state.isLoadingMoreSongs || !state.hasMoreSongs) return;

    emit(state.copyWith(isLoadingMoreSongs: true));

    try {
      final nextPage = (state.favoriteSongs.length ~/ _pageSize) + 1;
      final response = await _libraryService.getFavoriteSongs(
        page: nextPage,
        limit: _pageSize,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          favoriteSongs: [...state.favoriteSongs, ...response.data],
          totalSongs: response.total,
          isLoadingMoreSongs: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingMoreSongs: false));
    }
  }

  Future<void> toggleFavoriteSong(
    String videoId,
    String songIdOrVideoId, {
    bool currentlyFavorite = false,
    String? title,
    String? artist,
    String? thumbnail,
    int? duration,
    String? streamUrl,
  }) async {
    try {
      if (currentlyFavorite) {
        await _libraryService.removeFavoriteSong(videoId);
      } else {
        await _libraryService.addFavoriteSong(
          videoId,
          title: title,
          artist: artist,
          thumbnail: thumbnail,
          duration: duration,
          streamUrl: streamUrl,
        );
      }

      if (isClosed) return;
      await loadLibrary();
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(errorMessage: _parseError(e)));
    }
  }

  NowPlayingData playSong(FavoriteSong song) {
    final nowPlayingData = _mapFavoriteSongToNowPlaying(song);
    // NO disparamos LoadTrackEvent aquí - PlayerScreen lo hace
    return nowPlayingData;
  }

  NowPlayingData? playAllFavoriteSongsFromIndex(
    List<FavoriteSong> songs,
    int startIndex,
  ) {
    if (songs.isEmpty) return null;
    if (startIndex < 0 || startIndex >= songs.length) startIndex = 0;

    final playlist = songs.map(_mapFavoriteSongToNowPlaying).toList();

    _playerBloc.add(
      LoadPlaylistEvent(
        playlist: playlist,
        startIndex: startIndex,
        sourceId: 'library',
      ),
    );
    return playlist[startIndex];
  }

  NowPlayingData? playAllFavoriteSongs(List<FavoriteSong> songs) {
    if (songs.isEmpty) return null;

    final playlist = songs.map(_mapFavoriteSongToNowPlaying).toList();

    int startIndex = 0;
    final currentTrack = _playerBloc.state.currentTrack;

    if (currentTrack != null) {
      final currentIndex = playlist.indexWhere(
        (track) => track.videoId == currentTrack.videoId,
      );
      if (currentIndex != -1) {
        startIndex = currentIndex;
      }
    }

    _playerBloc.add(
      LoadPlaylistEvent(
        playlist: playlist,
        startIndex: startIndex,
        sourceId: 'library',
      ),
    );
    return playlist[startIndex];
  }

  NowPlayingData _mapFavoriteSongToNowPlaying(FavoriteSong song) {
    return NowPlayingData.fromBasic(
      videoId: song.videoId,
      title: song.title,
      artistNames: song.artist.split(', '),
      albumName: '',
      duration: song.duration != null
          ? _formatDuration(song.duration!)
          : '0:00',
      durationSeconds: song.duration,
      thumbnailUrl: song.thumbnail,
      streamUrl: song.streamUrl,
    );
  }

  Future<void> createPlaylist(String name) async {
    try {
      await _libraryService.createUserPlaylist(name: name);
      await loadLibrary();
    } catch (e) {
      emit(state.copyWith(errorMessage: _parseError(e)));
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  void reset() {
    emit(const LibraryState());
  }

  String _parseError(dynamic error) {
    if (error is AppException) {
      return getErrorMessage(error);
    }
    return error?.toString() ?? 'An error occurred';
  }
}
