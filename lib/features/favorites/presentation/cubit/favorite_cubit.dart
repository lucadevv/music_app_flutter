import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/library_service.dart';

part 'favorite_state.dart';

/// Cubit para manejar favoritos con estado optimista
class FavoriteCubit extends Cubit<FavoriteState> with BaseBlocMixin {
  final LibraryService _libraryService;
  
  final _favoritesController = StreamController<FavoriteEvent>.broadcast();
  Stream<FavoriteEvent> get favoritesStream => _favoritesController.stream;

  FavoriteCubit(this._libraryService) : super(const FavoriteState()) {
    loadFavorites();
  }

  bool isSongFavorite(String videoId) => state.favoriteSongs.contains(videoId);
  bool isPlaylistFavorite(String playlistId) => state.favoritePlaylists.contains(playlistId);
  bool isGenreFavorite(String externalParams) => state.favoriteGenres.contains(externalParams);

  /// Toggle favorito con actualización optimista
  Future<void> toggleFavorite({
    required String videoId,
    String? songId,
    required FavoriteType type,
    required bool isCurrentlyFavorite,
    SongMetadata? metadata,
    PlaylistMetadata? playlistMetadata,
  }) async {
    // Guardar estado anterior para rollback
    final previousSongs = Set<String>.from(state.favoriteSongs);
    final previousPlaylists = Set<String>.from(state.favoritePlaylists);
    final previousGenres = Set<String>.from(state.favoriteGenres);

    // Actualización optimista inmediata
    if (type == FavoriteType.song) {
      if (isCurrentlyFavorite) {
        state.favoriteSongs.remove(videoId);
      } else {
        state.favoriteSongs.add(videoId);
      }
    } else if (type == FavoriteType.playlist) {
      if (isCurrentlyFavorite) {
        state.favoritePlaylists.remove(videoId);
      } else {
        state.favoritePlaylists.add(videoId);
      }
    } else if (type == FavoriteType.genre) {
      if (isCurrentlyFavorite) {
        state.favoriteGenres.remove(videoId);
      } else {
        state.favoriteGenres.add(videoId);
      }
    }

    emit(state.copyWith());

    // Notificar a otros widgets
    _favoritesController.add(FavoriteEvent(
      type: type,
      id: videoId,
      isFavorite: !isCurrentlyFavorite,
    ));

    try {
      if (isCurrentlyFavorite) {
        // Remover de favoritos
        switch (type) {
          case FavoriteType.song:
            await _libraryService.removeFavoriteSong(songId ?? videoId);
            break;
          case FavoriteType.playlist:
            await _libraryService.removeFavoritePlaylist(videoId);
            break;
          case FavoriteType.genre:
            await _libraryService.removeFavoriteGenre(videoId);
            break;
        }
      } else {
        // Agregar a favoritos
        switch (type) {
          case FavoriteType.song:
            await _libraryService.addFavoriteSong(
              videoId,
              title: metadata?.title,
              artist: metadata?.artist,
              thumbnail: metadata?.thumbnail,
              duration: metadata?.duration,
            );
            break;
          case FavoriteType.playlist:
            await _libraryService.addFavoritePlaylist(
              videoId,
              name: playlistMetadata?.name,
              thumbnail: playlistMetadata?.thumbnail,
              description: playlistMetadata?.description,
            );
            break;
          case FavoriteType.genre:
            await _libraryService.addFavoriteGenre(videoId);
            break;
        }
      }
    } catch (e) {
      // Rollback en caso de error
      emit(FavoriteState(
        favoriteSongs: previousSongs,
        favoritePlaylists: previousPlaylists,
        favoriteGenres: previousGenres,
        error: _parseError(e),
      ));

      // Notificar rollback
      _favoritesController.add(FavoriteEvent(
        type: type,
        id: videoId,
        isFavorite: isCurrentlyFavorite,
      ));

      if (kDebugMode) {
        debugPrint('Error toggling favorite: $e');
      }
    }
  }

  /// Cargar favoritos desde el backend
  Future<void> loadFavorites() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final songsResponse = await _libraryService.getFavoriteSongs(page: 1, limit: 100);
      final playlistsResponse = await _libraryService.getFavoritePlaylists(page: 1, limit: 100);
      final genresResponse = await _libraryService.getFavoriteGenres(page: 1, limit: 100);

      if (isClosed) return;

      emit(FavoriteState(
        favoriteSongs: songsResponse.data.map((s) => s.videoId).toSet(),
        favoritePlaylists: playlistsResponse.data.map((p) => p.externalPlaylistId).toSet(),
        favoriteGenres: genresResponse.data.map((g) => g.externalParams).toSet(),
        isLoading: false,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        error: _parseError(e),
      ));
    }
  }

  String _parseError(dynamic error) {
    if (error is AppException) {
      return getErrorMessage(error);
    }
    return error?.toString() ?? 'An error occurred';
  }

  @override
  Future<void> close() {
    _favoritesController.close();
    return super.close();
  }
}
