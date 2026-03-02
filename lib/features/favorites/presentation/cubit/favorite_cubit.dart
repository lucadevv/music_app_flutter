import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/offline/presentation/cubit/playlist_offline_cubit.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

part 'favorite_state.dart';

/// Cubit para manejar favoritos con estado optimista
class FavoriteCubit extends Cubit<FavoriteState> with BaseBlocMixin {
  final LibraryService _libraryService;
  final PlaylistOfflineCubit _playlistOfflineCubit;
  final OfflineService _offlineService;
  final PlayerBlocBloc _playerBloc;

  final _favoritesController = StreamController<FavoriteEvent>.broadcast();
  Stream<FavoriteEvent> get favoritesStream => _favoritesController.stream;

  FavoriteCubit(
    this._libraryService,
    this._playlistOfflineCubit,
    this._offlineService,
    this._playerBloc,
  ) : super(const FavoriteState()) {
    loadFavorites();
  }

  bool isSongFavorite(String videoId) => state.favoriteSongs.contains(videoId);
  bool isPlaylistFavorite(String playlistId) =>
      state.favoritePlaylists.contains(playlistId);
  bool isGenreFavorite(String externalParams) =>
      state.favoriteGenres.contains(externalParams);

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
    _favoritesController.add(
      FavoriteEvent(type: type, id: videoId, isFavorite: !isCurrentlyFavorite),
    );

    try {
      if (isCurrentlyFavorite) {
        // Remover de favoritos
        switch (type) {
          case FavoriteType.song:
            await _libraryService.removeFavoriteSong(songId ?? videoId);
            break;
          case FavoriteType.playlist:
            await _libraryService.removeFavoritePlaylist(videoId);
            // Sincronizar offline: eliminar del caché (fire and forget)
            _removePlaylistFromOfflineCache(videoId);
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
              trackCount: playlistMetadata?.trackCount,
            );
            // Sincronizar offline: agregar al caché (fire and forget)
            _syncPlaylistToOfflineCache(
              externalPlaylistId: videoId,
              metadata: playlistMetadata,
            );
            break;
          case FavoriteType.genre:
            await _libraryService.addFavoriteGenre(videoId);
            break;
        }
      }
    } catch (e) {
      // Rollback en caso de error
      emit(
        FavoriteState(
          favoriteSongs: previousSongs,
          favoritePlaylists: previousPlaylists,
          favoriteGenres: previousGenres,
          error: _parseError(e),
        ),
      );

      // Notificar rollback
      _favoritesController.add(
        FavoriteEvent(type: type, id: videoId, isFavorite: isCurrentlyFavorite),
      );

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
      final songsResponse = await _libraryService.getFavoriteSongs(
        page: 1,
        limit: 100,
      );
      final playlistsResponse = await _libraryService.getFavoritePlaylists(
        page: 1,
        limit: 100,
      );
      final genresResponse = await _libraryService.getFavoriteGenres(
        page: 1,
        limit: 100,
      );

      if (isClosed) return;

      emit(
        FavoriteState(
          favoriteSongs: songsResponse.data.map((s) => s.videoId).toSet(),
          favoritePlaylists: playlistsResponse.data
              .map((p) => p.externalPlaylistId)
              .toSet(),
          favoriteGenres: genresResponse.data
              .map((g) => g.externalParams)
              .toSet(),
          isLoading: false,
        ),
      );

      // Sincronizar playlists favoritas con caché offline (fire and forget)
      _syncAllPlaylistsToOfflineCache(playlistsResponse.data);
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: _parseError(e)));
    }
  }

  /// Sincroniza una playlist al caché offline (fire and forget)
  ///
  /// Este método no bloquea la UI ni causa rollback si falla.
  /// Verifica conexión antes de intentar sincronizar.
  Future<void> _syncPlaylistToOfflineCache({
    required String externalPlaylistId,
    PlaylistMetadata? metadata,
  }) async {
    try {
      // Verificar conexión antes de sincronizar
      if (!await _offlineService.isOnline) {
        if (kDebugMode) {
          debugPrint('Offline: skipping playlist sync for $externalPlaylistId');
        }
        return;
      }

      // Crear FavoritePlaylist con los datos disponibles
      // Usamos externalPlaylistId como playlistId temporal hasta que se recargue
      final playlistData = FavoritePlaylist(
        id: '',
        playlistId: externalPlaylistId,
        externalPlaylistId: externalPlaylistId,
        name: metadata?.name ?? '',
        description: metadata?.description,
        thumbnail: metadata?.thumbnail,
        trackCount: null,
        createdAt: DateTime.now(),
      );

      // Sincronizar con caché offline
      await _playlistOfflineCubit.syncPlaylist(playlistData);

      if (kDebugMode) {
        debugPrint('Playlist synced to offline cache: $externalPlaylistId');
      }
    } catch (e) {
      // Log error pero no propagar - es fire and forget
      if (kDebugMode) {
        debugPrint('Error syncing playlist to offline cache: $e');
      }
    }
  }

  /// Elimina una playlist del caché offline (fire and forget)
  ///
  /// Este método no bloquea la UI ni causa rollback si falla.
  Future<void> _removePlaylistFromOfflineCache(String playlistId) async {
    try {
      await _playlistOfflineCubit.removeOfflinePlaylist(playlistId);

      if (kDebugMode) {
        debugPrint('Playlist removed from offline cache: $playlistId');
      }
    } catch (e) {
      // Log error pero no propagar - es fire and forget
      if (kDebugMode) {
        debugPrint('Error removing playlist from offline cache: $e');
      }
    }
  }

  /// Sincroniza todas las playlists favoritas con el caché offline (fire and forget)
  ///
  /// Este método no bloquea la UI ni causa rollback si falla.
  /// Verifica conexión antes de intentar sincronizar.
  Future<void> _syncAllPlaylistsToOfflineCache(
    List<FavoritePlaylist> playlists,
  ) async {
    try {
      // Verificar conexión antes de sincronizar
      if (!await _offlineService.isOnline) {
        if (kDebugMode) {
          debugPrint('Offline: skipping sync all playlists');
        }
        return;
      }

      await _playlistOfflineCubit.syncAllFavoritePlaylists(playlists);

      if (kDebugMode) {
        debugPrint(
          'All favorite playlists synced to offline cache: ${playlists.length}',
        );
      }
    } catch (e) {
      // Log error pero no propagar - es fire and forget
      if (kDebugMode) {
        debugPrint('Error syncing all playlists to offline cache: $e');
      }
    }
  }

  /// Reproduce una canción específica
  void playSong(FavoriteSong song) {
    final nowPlayingData = _mapToNowPlaying(song);
    _playerBloc.add(LoadTrackEvent(nowPlayingData));
  }

  /// Reproduce todas las canciones
  void playAllSongs(List<FavoriteSong> songs) {
    if (songs.isEmpty) return;

    final playlist = songs.map(_mapToNowPlaying).toList();
    _playerBloc.add(LoadPlaylistEvent(playlist: playlist, startIndex: 0));
  }

  /// Elimina una canción de favoritos
  void removeSong(FavoriteSong song) {
    toggleFavorite(
      videoId: song.videoId,
      songId: song.songId,
      type: FavoriteType.song,
      isCurrentlyFavorite: true,
    );
  }

  NowPlayingData _mapToNowPlaying(FavoriteSong song) {
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
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
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
