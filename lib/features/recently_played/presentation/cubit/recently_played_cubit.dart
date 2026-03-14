import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';
import 'package:music_app/features/recently_played/domain/usecases/get_recently_played_usecase.dart';

part 'recently_played_state.dart';

/// Cubit for recently played songs
class RecentlyPlayedCubit extends Cubit<RecentlyPlayedState>
    with BaseBlocMixin {
  final GetRecentlyPlayedUseCase _getRecentlyPlayedUseCase;
  final PlayerBlocBloc _playerBloc;

  RecentlyPlayedCubit({
    required GetRecentlyPlayedUseCase getRecentlyPlayedUseCase,
    required PlayerBlocBloc playerBloc,
  })  : _getRecentlyPlayedUseCase = getRecentlyPlayedUseCase,
        _playerBloc = playerBloc,
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

  /// Play a specific song
  NowPlayingData playSong(RecentlyPlayedSong song) {
    final nowPlayingData = NowPlayingData.fromBasic(
      videoId: song.videoId,
      title: song.title,
      artistNames: [song.artist],
      albumName: '',
      duration: song.duration,
      durationSeconds: song.durationSeconds,
      thumbnailUrl: song.thumbnail,
      streamUrl: song.streamUrl, // Incluir streamUrl si está disponible
    );

    _playerBloc.add(LoadTrackEvent(nowPlayingData));
    return nowPlayingData;
  }

  /// Refresh recently played songs
  Future<void> refresh() async {
    await loadRecentlyPlayed();
  }
}
