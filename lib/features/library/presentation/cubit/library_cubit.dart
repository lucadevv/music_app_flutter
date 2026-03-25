import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/data/offline/models/offline_playlist.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/domain/entities/library_entities.dart';
import 'package:music_app/features/library/domain/use_cases/add_favorite_song_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/create_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/get_favorite_genres_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/get_favorite_playlists_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/get_favorite_songs_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/get_library_summary_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/get_user_playlists_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/remove_favorite_song_use_case.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

part 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> with BaseBlocMixin {
  final GetLibrarySummaryUseCase _getLibrarySummaryUseCase;
  final GetFavoriteSongsUseCase _getFavoriteSongsUseCase;
  final GetFavoritePlaylistsUseCase _getFavoritePlaylistsUseCase;
  final GetFavoriteGenresUseCase _getFavoriteGenresUseCase;
  final GetUserPlaylistsUseCase _getUserPlaylistsUseCase;
  final AddFavoriteSongUseCase _addFavoriteSongUseCase;
  final RemoveFavoriteSongUseCase _removeFavoriteSongUseCase;
  final CreateUserPlaylistUseCase _createUserPlaylistUseCase;
  final OfflineService _offlineService;
  final PlayerBlocBloc _playerBloc;

  static const int _pageSize = 10;

  LibraryCubit({
    required GetLibrarySummaryUseCase getLibrarySummaryUseCase,
    required GetFavoriteSongsUseCase getFavoriteSongsUseCase,
    required GetFavoritePlaylistsUseCase getFavoritePlaylistsUseCase,
    required GetFavoriteGenresUseCase getFavoriteGenresUseCase,
    required GetUserPlaylistsUseCase getUserPlaylistsUseCase,
    required AddFavoriteSongUseCase addFavoriteSongUseCase,
    required RemoveFavoriteSongUseCase removeFavoriteSongUseCase,
    required CreateUserPlaylistUseCase createUserPlaylistUseCase,
    required OfflineService offlineService,
    required PlayerBlocBloc playerBloc,
  }) : _getLibrarySummaryUseCase = getLibrarySummaryUseCase,
       _getFavoriteSongsUseCase = getFavoriteSongsUseCase,
       _getFavoritePlaylistsUseCase = getFavoritePlaylistsUseCase,
       _getFavoriteGenresUseCase = getFavoriteGenresUseCase,
       _getUserPlaylistsUseCase = getUserPlaylistsUseCase,
       _addFavoriteSongUseCase = addFavoriteSongUseCase,
       _removeFavoriteSongUseCase = removeFavoriteSongUseCase,
       _createUserPlaylistUseCase = createUserPlaylistUseCase,
       _offlineService = offlineService,
       _playerBloc = playerBloc,
       super(const LibraryState());

  Future<void> loadLibrary() async {
    if (state.status == LibraryStatus.loading) return;

    emit(state.copyWith(status: LibraryStatus.loading, clearError: true));

    try {
      final isOnline = await _offlineService.isOnline;

      if (!isOnline) {
        await _loadOfflineLibrary();
        return;
      }

      // Execute use cases
      final songsResult = await _getFavoriteSongsUseCase(
        page: 1,
        limit: _pageSize,
      );
      final playlistsResult = await _getFavoritePlaylistsUseCase(
        page: 1,
        limit: _pageSize,
      );
      final userPlaylistsResult = await _getUserPlaylistsUseCase(
        page: 1,
        limit: 20,
      );
      final genresResult = await _getFavoriteGenresUseCase(
        page: 1,
        limit: _pageSize,
      );
      final summaryResult = await _getLibrarySummaryUseCase();

      // Convert Song to FavoriteSong for UI compatibility
      final List<FavoriteSong> favoriteSongs = songsResult.fold(
        (error) => <FavoriteSong>[],
        (songs) => songs.map(_mapSongToFavoriteSong).toList(),
      );

      // Get favorite playlists
      final List<FavoritePlaylist> favoritePlaylists = playlistsResult.fold(
        (error) => <FavoritePlaylist>[],
        (entities) => entities.map(_mapEntityToFavoritePlaylist).toList(),
      );

      // Get user playlists
      final List<UserPlaylist> userPlaylists = userPlaylistsResult.fold(
        (error) => <UserPlaylist>[],
        (playlists) => playlists,
      );

      // Get favorite genres
      final List<FavoriteGenre> favoriteGenres = genresResult.fold(
        (error) => <FavoriteGenre>[],
        (entities) => entities.map(_mapEntityToFavoriteGenre).toList(),
      );

      // Get summary
      final LibrarySummary? summary = summaryResult.fold(
        (error) => null,
        (entity) => LibrarySummary(
          favoriteSongs: entity.favoriteSongsCount,
          favoritePlaylists: entity.favoritePlaylistsCount,
          favoriteGenres: entity.favoriteGenresCount,
        ),
      );

      final allPlaylists = <PlaylistItem>[];

      for (final userPlaylist in userPlaylists) {
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

      for (final favPlaylist in favoritePlaylists) {
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

      // Calculate totals from results
      final int totalSongs = songsResult.fold(
        (_) => 0,
        (songs) => songs.length,
      );
      final int totalPlaylists =
          userPlaylistsResult.fold((_) => 0, (playlists) => playlists.length) +
          playlistsResult.fold((_) => 0, (playlists) => playlists.length);
      final int totalGenres = genresResult.fold(
        (_) => 0,
        (genres) => genres.length,
      );

      emit(
        state.copyWith(
          status: LibraryStatus.success,
          favoriteSongs: favoriteSongs,
          favoritePlaylists: favoritePlaylists,
          userPlaylists: userPlaylists,
          allPlaylists: allPlaylists,
          favoriteGenres: favoriteGenres,
          totalSongs: totalSongs,
          totalPlaylists: totalPlaylists,
          totalGenres: totalGenres,
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

  /// Map Song domain entity to FavoriteSong (for UI compatibility)
  FavoriteSong _mapSongToFavoriteSong(Song song) {
    return FavoriteSong(
      id: song.videoId,
      songId: song.videoId,
      videoId: song.videoId,
      title: song.title,
      artist: song.artist,
      thumbnail: song.thumbnail,
      duration: song.durationSeconds,
      streamUrl: song.streamUrl,
      createdAt: DateTime.now(),
    );
  }

  /// Map FavoritePlaylistEntity to FavoritePlaylist (for UI compatibility)
  FavoritePlaylist _mapEntityToFavoritePlaylist(FavoritePlaylistEntity entity) {
    return FavoritePlaylist(
      id: entity.id,
      playlistId: entity.id,
      externalPlaylistId: entity.id,
      name: entity.name ?? '',
      description: entity.description,
      thumbnail: entity.thumbnail,
      trackCount: entity.trackCount,
      cachedTrackCount: entity.trackCount,
      createdAt: DateTime.now(),
    );
  }

  /// Map FavoriteGenreEntity to FavoriteGenre (for UI compatibility)
  FavoriteGenre _mapEntityToFavoriteGenre(FavoriteGenreEntity entity) {
    return FavoriteGenre(
      id: entity.id,
      genreId: entity.id,
      externalParams: entity.externalParams,
      name: entity.name ?? '',
      createdAt: DateTime.now(),
    );
  }

  Future<void> loadMoreSongs() async {
    if (state.isLoadingMoreSongs || !state.hasMoreSongs) return;

    emit(state.copyWith(isLoadingMoreSongs: true));

    try {
      final nextPage = (state.favoriteSongs.length ~/ _pageSize) + 1;
      final result = await _getFavoriteSongsUseCase(
        page: nextPage,
        limit: _pageSize,
      );

      if (isClosed) return;

      final newSongs = result.fold(
        (error) => <FavoriteSong>[],
        (songs) => songs.map(_mapSongToFavoriteSong).toList(),
      );

      emit(
        state.copyWith(
          favoriteSongs: [...state.favoriteSongs, ...newSongs],
          totalSongs: state.totalSongs + newSongs.length,
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
        await _removeFavoriteSongUseCase(videoId);
      } else {
        // Create a Song entity from the parameters
        final song = Song(
          videoId: videoId,
          title: title ?? '',
          artist: artist ?? '',
          artistNames: artist?.split(', ') ?? [],
          thumbnail: thumbnail,
          streamUrl: streamUrl,
          durationSeconds: duration ?? 0,
        );
        await _addFavoriteSongUseCase(song);
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
      await _createUserPlaylistUseCase(name: name);
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
