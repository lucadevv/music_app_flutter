import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/domain/entities/library_entities.dart';
import 'package:music_app/features/library/domain/use_cases/create_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/get_favorite_playlists_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/get_user_playlists_use_case.dart';
import 'package:music_app/features/user_playlists/presentation/cubit/user_playlists_state.dart';

/// Cubit para manejar playlists de usuario
///
/// Responsibilities:
/// - Cargar todas las playlists (user + favorites)
/// - Crear nueva playlist
/// - Sincronizar con offline
class UserPlaylistsCubit extends Cubit<UserPlaylistsState> with BaseBlocMixin {
  final GetUserPlaylistsUseCase _getUserPlaylistsUseCase;
  final GetFavoritePlaylistsUseCase _getFavoritePlaylistsUseCase;
  final CreateUserPlaylistUseCase _createUserPlaylistUseCase;

  UserPlaylistsCubit({
    required GetUserPlaylistsUseCase getUserPlaylistsUseCase,
    required GetFavoritePlaylistsUseCase getFavoritePlaylistsUseCase,
    required CreateUserPlaylistUseCase createUserPlaylistUseCase,
  }) : _getUserPlaylistsUseCase = getUserPlaylistsUseCase,
       _getFavoritePlaylistsUseCase = getFavoritePlaylistsUseCase,
       _createUserPlaylistUseCase = createUserPlaylistUseCase,
       super(const UserPlaylistsState());

  /// Carga todas las playlists (user + favorites)
  Future<void> loadAllPlaylists() async {
    emit(state.copyWith(status: UserPlaylistsStatus.loading));

    try {
      // Cargar playlists del usuario Y playlists favoritas
      final userPlaylistsResult = await _getUserPlaylistsUseCase();
      final favoritePlaylistsResult = await _getFavoritePlaylistsUseCase();

      final userPlaylists = userPlaylistsResult.fold<List<UserPlaylist>>(
        (error) => <UserPlaylist>[],
        (data) => data,
      );

      final favoritePlaylists = favoritePlaylistsResult
          .fold<List<FavoritePlaylistEntity>>(
            (error) => <FavoritePlaylistEntity>[],
            (data) => data,
          );

      // Recopilar IDs de playlists del usuario
      final userPlaylistIds = userPlaylists.map((p) => p.id).toSet();

      // Filtrar favorites para evitar duplicados
      // Note: FavoritePlaylistEntity uses 'id' instead of 'playlistId'
      final uniqueFavorites = favoritePlaylists
          .where((p) => !userPlaylistIds.contains(p.id))
          .where((p) => (p.trackCount ?? 0) > 0)
          .toList();

      final playlists = <PlaylistItem>[
        ...userPlaylists.map(
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
            name: p.name ?? 'Favorite Playlist',
            thumbnail: p.thumbnail,
            songCount: p.trackCount ?? 0,
            type: PlaylistType.favorite,
            externalId:
                null, // FavoritePlaylistEntity doesn't have externalPlaylistId
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
      await _createUserPlaylistUseCase(name: name);
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
