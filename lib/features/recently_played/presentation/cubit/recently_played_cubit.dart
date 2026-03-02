import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';

part 'recently_played_state.dart';

/// Cubit for recently played songs
class RecentlyPlayedCubit extends Cubit<RecentlyPlayedState> with BaseBlocMixin {
  final ApiServices _apiServices;
  final PlayerBlocBloc _playerBloc;

  RecentlyPlayedCubit({
    required ApiServices apiServices,
    required PlayerBlocBloc playerBloc,
  })  : _apiServices = apiServices,
        _playerBloc = playerBloc,
        super(const RecentlyPlayedState());

  /// Load recently played songs from API
  Future<void> loadRecentlyPlayed() async {
    if (state.status == RecentlyPlayedStatus.loading) return;

    emit(state.copyWith(
      status: RecentlyPlayedStatus.loading,
      clearError: true,
    ));

    try {
      final response = await _apiServices.get('/music/recently-listened');
      // Robust extraction depending on the shape of the response
      final List<dynamic> songsData = (
            response is Map<String, dynamic> && response['songs'] is List
          ) ? (response['songs'] as List<dynamic>) : [];

      final songs = songsData
          .map((json) => RecentlyPlayedSong.fromJson(json as Map<String, dynamic>))
          .toList();

      if (isClosed) return;

      emit(state.copyWith(
        status: RecentlyPlayedStatus.success,
        songs: songs,
      ));
    } catch (e) {
      if (isClosed) return;
      final errorMessage = e is AppException ? getErrorMessage(e) : e.toString();
      emit(state.copyWith(
        status: RecentlyPlayedStatus.failure,
        errorMessage: errorMessage,
      ));
    }
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
    );

    _playerBloc.add(LoadTrackEvent(nowPlayingData));
    return nowPlayingData;
  }

  /// Refresh recently played songs
  Future<void> refresh() async {
    await loadRecentlyPlayed();
  }
}
