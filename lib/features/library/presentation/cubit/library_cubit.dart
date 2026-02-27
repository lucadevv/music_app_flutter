import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/library_service.dart';

part 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> with BaseBlocMixin {
  final LibraryService _libraryService;

  LibraryCubit(this._libraryService) : super(const LibraryState());

  Future<void> loadLibrary() async {
    if (state.status == LibraryStatus.loading) return;

    emit(state.copyWith(status: LibraryStatus.loading, clearError: true));

    try {
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
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: LibraryStatus.failure,
        errorMessage: _parseError(e),
      ));
    }
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
