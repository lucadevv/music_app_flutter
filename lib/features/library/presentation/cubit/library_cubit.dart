import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/data/offline/models/offline_playlist.dart';
import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

part 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> with BaseBlocMixin {
  final LibraryService _libraryService;
  final OfflineService _offlineService;
  final PlayerBlocBloc _playerBloc;

  LibraryCubit(this._libraryService, this._offlineService, this._playerBloc)
    : super(const LibraryState());

  Future<void> loadLibrary() async {
    if (state.status == LibraryStatus.loading) return;

    emit(state.copyWith(status: LibraryStatus.loading, clearError: true));

    try {
      // Verificar conexión a internet
      final isOnline = await _offlineService.isOnline;

      if (!isOnline) {
        // Modo offline: cargar playlists desde almacenamiento local
        await _loadOfflineLibrary();
        return;
      }

      // Modo online: comportamiento normal
      final songsResponse = await _libraryService.getFavoriteSongs(
        page: 1,
        limit: 10,
      );
      final playlistsResponse = await _libraryService.getFavoritePlaylists(
        page: 1,
        limit: 10,
      );
      final userPlaylistsResponse = await _libraryService.getUserPlaylists(
        page: 1,
        limit: 20,
      );
      final genresResponse = await _libraryService.getFavoriteGenres(
        page: 1,
        limit: 10,
      );
      final summary = await _libraryService.getLibrarySummary();

      // Combinar playlists del usuario + playlists favoritas de YouTube
      final allPlaylists = <PlaylistItem>[];

      // Agregar playlists creadas por el usuario
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

      // Agregar playlists favoritas de YouTube
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
          totalPlaylists:
              userPlaylistsResponse.total +
              playlistsResponse.total, // Todas las playlists
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

  /// Carga la librería desde el almacenamiento offline
  Future<void> _loadOfflineLibrary() async {
    try {
      final offlinePlaylists = await _offlineService.getOfflinePlaylists();

      // Convertir OfflinePlaylist a FavoritePlaylist
      final favoritePlaylists = offlinePlaylists
          .map(_convertToFavoritePlaylist)
          .toList();

      if (isClosed) return;

      emit(
        state.copyWith(
          status: LibraryStatus.success,
          favoriteSongs: const [], // No hay canciones offline en este flujo
          favoritePlaylists: favoritePlaylists,
          favoriteGenres: const [], // No hay géneros offline
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

  /// Convierte un OfflinePlaylist a FavoritePlaylist
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
      final nextPage = (state.favoriteSongs.length ~/ 20) + 1;
      final response = await _libraryService.getFavoriteSongs(
        page: nextPage,
        limit: 20,
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
        // El backend ahora acepta videoId directamente
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

  /// Reproduce una canción específica
  /// Retorna el NowPlayingData para navegación
  NowPlayingData playSong(FavoriteSong song) {
    final nowPlayingData = _mapFavoriteSongToNowPlaying(song);
    _playerBloc.add(LoadTrackEvent(nowPlayingData));
    return nowPlayingData;
  }

  /// Reproduce todas las canciones de favoritos
  /// Retorna el primer NowPlayingData para navegación
  /// Si ya hay una canción de la lista reproduciéndose, continúa desde esa posición
  NowPlayingData? playAllFavoriteSongs(List<FavoriteSong> songs) {
    if (songs.isEmpty) return null;

    final playlist = songs.map(_mapFavoriteSongToNowPlaying).toList();

    // Verificar si hay una canción reproduciéndose actualmente que esté en la playlist
    int startIndex = 0;
    final currentTrack = _playerBloc.state.currentTrack;
    
    if (currentTrack != null) {
      // Buscar el índice de la canción actual en la nueva playlist
      final currentIndex = playlist.indexWhere(
        (track) => track.videoId == currentTrack.videoId,
      );
      if (currentIndex != -1) {
        startIndex = currentIndex;
      }
    }

     _playerBloc.add(LoadPlaylistEvent(
       playlist: playlist,
       startIndex: startIndex,
       sourceId: 'library',
     ));
     return playlist[startIndex];
   }

  /// Helper: map a FavoriteSong to NowPlayingData using existing fields
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

  /// Crea una nueva playlist
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
