import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/liked/domain/entities/liked_song_entity.dart';
import 'package:music_app/features/liked/domain/use_cases/add_liked_song_use_case.dart';
import 'package:music_app/features/liked/domain/use_cases/get_liked_songs_use_case.dart';
import 'package:music_app/features/liked/domain/use_cases/is_song_liked_use_case.dart';
import 'package:music_app/features/liked/domain/use_cases/remove_liked_song_use_case.dart';

part 'liked_songs_state.dart';

class LikedSongsCubit extends Cubit<LikedSongsState> with BaseBlocMixin {
  final GetLikedSongsUseCase _getLikedSongsUseCase;
  final AddLikedSongUseCase _addLikedSongUseCase;
  final RemoveLikedSongUseCase _removeLikedSongUseCase;
  final IsSongLikedUseCase _isSongLikedUseCase;

  static const int _pageSize = 10;

  LikedSongsCubit({
    required GetLikedSongsUseCase getLikedSongsUseCase,
    required AddLikedSongUseCase addLikedSongUseCase,
    required RemoveLikedSongUseCase removeLikedSongUseCase,
    required IsSongLikedUseCase isSongLikedUseCase,
  }) : _getLikedSongsUseCase = getLikedSongsUseCase,
       _addLikedSongUseCase = addLikedSongUseCase,
       _removeLikedSongUseCase = removeLikedSongUseCase,
       _isSongLikedUseCase = isSongLikedUseCase,
       super(const LikedSongsState());

  Future<void> loadLikedSongs() async {
    if (state.status == LikedSongsStatus.loading) return;

    emit(state.copyWith(status: LikedSongsStatus.loading, clearError: true));

    try {
      final result = await _getLikedSongsUseCase(page: 1, limit: _pageSize);

      if (isClosed) return;

      result.fold(
        (error) {
          emit(
            state.copyWith(
              status: LikedSongsStatus.failure,
              errorMessage: _parseError(error),
            ),
          );
        },
        (entities) {
          final songs = entities.map(_mapEntityToFavoriteSong).toList();
          emit(
            state.copyWith(
              status: LikedSongsStatus.success,
              songs: songs,
              totalSongs: songs.length,
              clearError: true,
            ),
          );
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LikedSongsStatus.failure,
          errorMessage: _parseError(e),
        ),
      );
    }
  }

  Future<void> loadMoreSongs() async {
    if (state.isLoadingMore || !state.hasMoreSongs) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = (state.songs.length ~/ _pageSize) + 1;
      final result = await _getLikedSongsUseCase(
        page: nextPage,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (error) {
          emit(state.copyWith(isLoadingMore: false));
        },
        (entities) {
          final newSongs = entities.map(_mapEntityToFavoriteSong).toList();
          emit(
            state.copyWith(
              songs: [...state.songs, ...newSongs],
              totalSongs: state.totalSongs + newSongs.length,
              isLoadingMore: false,
            ),
          );
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> addSong({
    required String videoId,
    required String title,
    required String artist,
    String? thumbnail,
    int? duration,
    String? streamUrl,
  }) async {
    try {
      final entity = LikedSongEntity(
        videoId: videoId,
        title: title,
        artist: artist,
        thumbnail: thumbnail,
        duration: duration,
        streamUrl: streamUrl,
      );

      final result = await _addLikedSongUseCase(entity);

      if (isClosed) return;

      result.fold(
        (error) {
          emit(state.copyWith(errorMessage: _parseError(error)));
        },
        (_) {
          // Reload to get updated list
          loadLikedSongs();
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(errorMessage: _parseError(e)));
    }
  }

  Future<void> removeSong(String videoId) async {
    try {
      final result = await _removeLikedSongUseCase(videoId);

      if (isClosed) return;

      result.fold(
        (error) {
          emit(state.copyWith(errorMessage: _parseError(error)));
        },
        (_) {
          // Remove from local state immediately for better UX
          final updatedSongs = state.songs
              .where((song) => song.videoId != videoId)
              .toList();
          emit(
            state.copyWith(
              songs: updatedSongs,
              totalSongs: state.totalSongs - 1,
            ),
          );
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(errorMessage: _parseError(e)));
    }
  }

  Future<bool> isSongLiked(String videoId) async {
    try {
      final result = await _isSongLikedUseCase(videoId);
      return result.fold((error) => false, (isLiked) => isLiked);
    } catch (e) {
      return false;
    }
  }

  FavoriteSong _mapEntityToFavoriteSong(LikedSongEntity entity) {
    return FavoriteSong(
      id: entity.videoId,
      songId: entity.videoId,
      videoId: entity.videoId,
      title: entity.title,
      artist: entity.artist,
      thumbnail: entity.thumbnail,
      duration: entity.duration,
      streamUrl: entity.streamUrl,
      createdAt: entity.addedAt ?? DateTime.now(),
    );
  }

  String _parseError(dynamic error) {
    if (error is AppException) {
      return getErrorMessage(error);
    }
    return error?.toString() ?? 'An error occurred';
  }
}
