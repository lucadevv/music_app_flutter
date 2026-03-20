import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/domain/player_facade.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';
import 'package:music_app/features/recently_played/domain/usecases/get_recently_played_usecase.dart';

part 'recently_played_state.dart';

/// Cubit for recently played songs
class RecentlyPlayedCubit extends Cubit<RecentlyPlayedState>
    with BaseBlocMixin {
  final GetRecentlyPlayedUseCase _getRecentlyPlayedUseCase;
  final PlayerFacade _player;

  RecentlyPlayedCubit({
    required GetRecentlyPlayedUseCase getRecentlyPlayedUseCase,
    required PlayerFacade player,
  })  : _getRecentlyPlayedUseCase = getRecentlyPlayedUseCase,
        _player = player,
        super(const RecentlyPlayedState());

  /// Load recently played songs from API
  Future<void> loadRecentlyPlayed() async {
    if (state.status == RecentlyPlayedStatus.loading) return;

    emit(
      state.copyWith(status: RecentlyPlayedStatus.loading, clearError: true),
    );

    final result = await _getRecentlyPlayedUseCase();

    result.fold(
      (error) {
        if (isClosed) return;
        final errorMessage = getErrorMessage(error);
        emit(
          state.copyWith(
            status: RecentlyPlayedStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (songs) {
        if (isClosed) return;
        emit(state.copyWith(status: RecentlyPlayedStatus.success, songs: songs));
      },
    );
  }

  /// Play a specific song using PlayRequestEvent
  /// El PlayerBloc decide si es LoadTrackEvent (canción nueva) o PlayTrackAtIndexEvent (ya está en playlist)
  NowPlayingData playSong(RecentlyPlayedSong song) {
    final nowPlayingData = _mapToNowPlaying(song);

    _player.playSingle(nowPlayingData);
    return nowPlayingData;
  }

  /// Play all recently played songs from a specific index (playlist mode)
  /// Útil cuando quieres reproducir toda la lista desde una canción específica
  NowPlayingData? playAllFromIndex(List<RecentlyPlayedSong> songs, int startIndex) {
    if (songs.isEmpty) return null;
    if (startIndex < 0 || startIndex >= songs.length) startIndex = 0;

    final playlist = songs.map(_mapToNowPlaying).toList();

    // Primero verificar si la canción ya está en la playlist actual del player
    final currentTrack = _player.state.currentTrack;
    final existingIndex = currentTrack != null 
        ? playlist.indexWhere((t) => t.videoId == currentTrack.videoId)
        : -1;

    if (existingIndex >= 0) {
      // Ya está en la playlist, solo cambiar al índice
      _player.playAtIndex(existingIndex);
      return playlist[existingIndex];
    }

    // No está en playlist, cargar la playlist completa
    _player.playPlaylist(
      playlist: playlist,
      startIndex: startIndex,
      sourceId: 'recently_played',
    );
    return playlist[startIndex];
  }

  NowPlayingData _mapToNowPlaying(RecentlyPlayedSong song) {
    return NowPlayingData.fromBasic(
      videoId: song.videoId,
      title: song.title,
      artistNames: [song.artist],
      albumName: '',
      duration: song.duration,
      durationSeconds: song.durationSeconds,
      thumbnailUrl: song.thumbnail,
      streamUrl: song.streamUrl,
    );
  }

  /// Refresh recently played songs
  Future<void> refresh() async {
    await loadRecentlyPlayed();
  }
}
