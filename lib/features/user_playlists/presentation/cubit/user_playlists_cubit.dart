import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/user_playlists/presentation/cubit/user_playlists_state.dart';

/// Cubit para manejar playlists de usuario
///
/// Responsibilities:
/// - Cargar todas las playlists (user + favorites)
/// - Crear nueva playlist
/// - Sincronizar con offline
class UserPlaylistsCubit extends Cubit<UserPlaylistsState> with BaseBlocMixin {
  final LibraryService _libraryService;

  UserPlaylistsCubit({required LibraryService libraryService})
    : _libraryService = libraryService,
      super(const UserPlaylistsState());

  /// Carga todas las playlists (user + favorites)
  Future<void> loadAllPlaylists() async {
    emit(state.copyWith(status: UserPlaylistsStatus.loading));

    try {
      // Cargar playlists del usuario Y playlists favoritas
      final userPlaylists = await _libraryService.getUserPlaylists();
      final favoritePlaylists = await _libraryService.getFavoritePlaylists();

      // Recopilar IDs de playlists del usuario
      final userPlaylistIds = userPlaylists.data.map((p) => p.id).toSet();

      // Filtrar favorites para evitar duplicados
      final uniqueFavorites = favoritePlaylists.data
          .where((p) => !userPlaylistIds.contains(p.playlistId))
          .where((p) => (p.cachedTrackCount ?? p.trackCount ?? 0) > 0)
          .toList();

      final playlists = <PlaylistItem>[
        ...userPlaylists.data.map(
          (p) => PlaylistItem(
            id: p.id,
            name: p.name,
            thumbnail: p.thumbnail,
            songCount: p.songCount,
            type: PlaylistType.user,
            externalId: null,
          ),
        ),
        ...uniqueFavorites.map(
          (p) => PlaylistItem(
            id: p.id,
            name: p.name,
            thumbnail: p.thumbnail,
            songCount: p.cachedTrackCount ?? p.trackCount ?? 0,
            type: PlaylistType.favorite,
            externalId: p.externalPlaylistId,
          ),
        ),
      ];

      emit(
        state.copyWith(
          status: UserPlaylistsStatus.success,
          playlists: playlists,
        ),
      );
    } catch (e) {
      final errorMessage = e.toString();
      emit(
        state.copyWith(
          status: UserPlaylistsStatus.failure,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  /// Crea una nueva playlist
  Future<void> createPlaylist(String name) async {
    try {
      await _libraryService.createUserPlaylist(name: name);
      await loadAllPlaylists();
    } catch (e) {
      // Use a safe string representation for errors to avoid type issues
      final errorMessage = e.toString();
      emit(
        state.copyWith(
          status: UserPlaylistsStatus.failure,
          errorMessage: errorMessage,
        ),
      );
    }
  }
}
