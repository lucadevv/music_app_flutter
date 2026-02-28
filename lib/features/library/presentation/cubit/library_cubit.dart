import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/data/offline/models/offline_playlist.dart';
import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/library/library_service.dart';

part 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> with BaseBlocMixin {
  final LibraryService _libraryService;
  final OfflineService _offlineService;

  LibraryCubit(this._libraryService, this._offlineService) : super(const LibraryState());

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
      final songsResponse = await _libraryService.getFavoriteSongs(page: 1, limit: 10);
      final playlistsResponse = await _libraryService.getFavoritePlaylists(page: 1, limit: 10);
      final genresResponse = await _libraryService.getFavoriteGenres(page: 1, limit: 10);
      final summary = await _libraryService.getLibrarySummary();

      if (isClosed) return;

      emit(state.copyWith(
        status: LibraryStatus.success,
        favoriteSongs: songsResponse.data,
        favoritePlaylists: playlistsResponse.data,
        favoriteGenres: genresResponse.data,
        totalSongs: songsResponse.total,
        totalPlaylists: playlistsResponse.total,
        totalGenres: genresResponse.total,
        summary: summary,
        clearError: true,
        isOffline: false,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: LibraryStatus.failure,
        errorMessage: _parseError(e),
      ));
    }
  }

  /// Carga la librería desde el almacenamiento offline
  Future<void> _loadOfflineLibrary() async {
    try {
      final offlinePlaylists = await _offlineService.getOfflinePlaylists();

      // Convertir OfflinePlaylist a FavoritePlaylist
      final favoritePlaylists = offlinePlaylists
          .map((offlinePlaylist) => _convertToFavoritePlaylist(offlinePlaylist))
          .toList();

      if (isClosed) return;

      emit(state.copyWith(
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
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: LibraryStatus.failure,
        errorMessage: _parseError(e),
        isOffline: true,
      ));
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
      thumbnail: offlinePlaylist.thumbnail ?? offlinePlaylist.localThumbnailPath,
      trackCount: offlinePlaylist.trackCount,
      createdAt: offlinePlaylist.createdAt,
    );
  }

  Future<void> loadMoreSongs() async {
    if (state.isLoadingMoreSongs || !state.hasMoreSongs) return;

    emit(state.copyWith(isLoadingMoreSongs: true));

    try {
      final nextPage = (state.favoriteSongs.length ~/ 20) + 1;
      final response = await _libraryService.getFavoriteSongs(page: nextPage, limit: 20);

      if (isClosed) return;

      emit(state.copyWith(
        favoriteSongs: [...state.favoriteSongs, ...response.data],
        totalSongs: response.total,
        isLoadingMoreSongs: false,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingMoreSongs: false));
    }
  }

  Future<void> toggleFavoriteSong(String videoId, String songIdOrVideoId, {bool currentlyFavorite = false}) async {
    try {
      if (currentlyFavorite) {
        // El backend ahora acepta videoId directamente
        await _libraryService.removeFavoriteSong(videoId);
      } else {
        await _libraryService.addFavoriteSong(videoId);
      }

      if (isClosed) return;
      await loadLibrary();
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(errorMessage: _parseError(e)));
    }
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
