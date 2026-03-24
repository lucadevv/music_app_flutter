import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

/// Hook para manejar la lógica de estado del PlayerScreen
class UsePlayerScreenStateResult {
  final bool hasRequestedPlay;
  final String? lastVideoId;
  final void Function(PlayerBlocBloc bloc, PlayerBlocState state)
  requestPlayIfNeeded;
  final void Function(String videoId) updateLastVideoId;
  final void Function() resetRequestedPlay;

  const UsePlayerScreenStateResult({
    required this.hasRequestedPlay,
    required this.lastVideoId,
    required this.requestPlayIfNeeded,
    required this.updateLastVideoId,
    required this.resetRequestedPlay,
  });
}

UsePlayerScreenStateResult usePlayerScreenState(
  NowPlayingData nowPlayingData, {
  bool playAsSingle = false,
}) {
  bool hasRequestedPlay = false;
  String? lastVideoId = nowPlayingData.videoId;

  void requestPlayIfNeeded(PlayerBlocBloc bloc, PlayerBlocState state) {
    if (hasRequestedPlay) return;
    if (nowPlayingData.videoId != lastVideoId) return;

    final hasValidUrl =
        nowPlayingData.streamUrl != null &&
        nowPlayingData.streamUrl!.isNotEmpty;
    if (!hasValidUrl) return;

    final isCurrentSong = state.currentTrack?.videoId == nowPlayingData.videoId;
    final isAlreadyPlaying = isCurrentSong && state.isPlaying;

    if (isAlreadyPlaying) return;

    hasRequestedPlay = true;

    if (playAsSingle) {
      bloc.add(
        LoadTrackEvent(
          nowPlayingData,
          sourceId: 'single:${nowPlayingData.videoId}',
        ),
      );
    } else {
      bloc.add(PlayRequestEvent(nowPlayingData));
    }
  }

  void updateLastVideoId(String videoId) {
    hasRequestedPlay = false;
    lastVideoId = videoId;
  }

  void resetRequestedPlay() {
    hasRequestedPlay = false;
  }

  return UsePlayerScreenStateResult(
    hasRequestedPlay: hasRequestedPlay,
    lastVideoId: lastVideoId,
    requestPlayIfNeeded: requestPlayIfNeeded,
    updateLastVideoId: updateLastVideoId,
    resetRequestedPlay: resetRequestedPlay,
  );
}
