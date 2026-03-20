import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

/// Punto único de entrada para iniciar reproducción desde UI/Features.
///
/// Mantiene consistencia de `sourceId` y centraliza la política "single vs playlist".
class PlayerFacade {
  final PlayerBlocBloc _bloc;

  PlayerFacade(this._bloc);

  PlayerBlocState get state => _bloc.state;

  void playSingle(NowPlayingData track, {String? sourceId}) {
    _bloc.add(
      LoadTrackEvent(
        track,
        sourceId: sourceId ?? 'single:${track.videoId}',
      ),
    );
  }

  void playPlaylist({
    required List<NowPlayingData> playlist,
    required String sourceId,
    int startIndex = 0,
  }) {
    _bloc.add(
      LoadPlaylistEvent(
        playlist: playlist,
        startIndex: startIndex,
        sourceId: sourceId,
      ),
    );
  }

  void playAtIndex(int index) {
    _bloc.add(PlayTrackAtIndexEvent(index));
  }

  void togglePlayPause() {
    _bloc.add(const PlayPauseToggleEvent());
  }

  void next() {
    _bloc.add(const NextTrackEvent());
  }

  void previous() {
    _bloc.add(const PreviousTrackEvent());
  }
}

