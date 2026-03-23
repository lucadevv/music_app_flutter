part of 'player_bloc_bloc.dart';

sealed class PlayerBlocEvent extends Equatable {
  const PlayerBlocEvent();

  @override
  List<Object?> get props => [];
}

class PlayEvent extends PlayerBlocEvent {
  const PlayEvent();
}

class PauseEvent extends PlayerBlocEvent {
  const PauseEvent();
}

class StopEvent extends PlayerBlocEvent {
  const StopEvent();
}

class PlayPauseToggleEvent extends PlayerBlocEvent {
  const PlayPauseToggleEvent();
}

class NextTrackEvent extends PlayerBlocEvent {
  const NextTrackEvent();
}

class PreviousTrackEvent extends PlayerBlocEvent {
  const PreviousTrackEvent();
}

class SeekEvent extends PlayerBlocEvent {
  final Duration position;

  const SeekEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayRequestEvent extends PlayerBlocEvent {
  final NowPlayingData track;
  final bool playAsSingle;

  const PlayRequestEvent(this.track, {this.playAsSingle = false});

  @override
  List<Object?> get props => [track, playAsSingle];
}

class LoadTrackEvent extends PlayerBlocEvent {
  final NowPlayingData track;
  final String? sourceId;

  const LoadTrackEvent(this.track, {this.sourceId});

  @override
  List<Object?> get props => [track, sourceId];
}

class LoadPlaylistEvent extends PlayerBlocEvent {
  final List<NowPlayingData> playlist;
  final int? startIndex;
  final String? sourceId;

  const LoadPlaylistEvent({
    required this.playlist,
    this.startIndex,
    this.sourceId,
  });

  @override
  List<Object?> get props => [playlist, startIndex, sourceId];
}

class PlayTrackAtIndexEvent extends PlayerBlocEvent {
  final int index;

  const PlayTrackAtIndexEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class AddToPlaylistEvent extends PlayerBlocEvent {
  final NowPlayingData track;

  const AddToPlaylistEvent(this.track);

  @override
  List<Object?> get props => [track];
}

class AddMultipleToPlaylistEvent extends PlayerBlocEvent {
  final List<NowPlayingData> tracks;
  final String? sourceId;

  const AddMultipleToPlaylistEvent(this.tracks, {this.sourceId});

  @override
  List<Object?> get props => [tracks, sourceId];
}

class RemoveFromPlaylistEvent extends PlayerBlocEvent {
  final int index;

  const RemoveFromPlaylistEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class SetVolumeEvent extends PlayerBlocEvent {
  final double volume;

  const SetVolumeEvent(this.volume);

  @override
  List<Object?> get props => [volume];
}

class SetSpeedEvent extends PlayerBlocEvent {
  final double speed;

  const SetSpeedEvent(this.speed);

  @override
  List<Object?> get props => [speed];
}

class SetLoopModeEvent extends PlayerBlocEvent {
  final LoopModeType loopMode;

  const SetLoopModeEvent(this.loopMode);

  @override
  List<Object?> get props => [loopMode];
}

class ToggleShuffleEvent extends PlayerBlocEvent {
  const ToggleShuffleEvent();
}

class AudioPlayerStateChangedEvent extends PlayerBlocEvent {
  final PlayerStateInfo playerState;

  const AudioPlayerStateChangedEvent(this.playerState);

  @override
  List<Object?> get props => [
    playerState.isPlaying,
    playerState.processingState,
  ];
}

class PositionChangedEvent extends PlayerBlocEvent {
  final Duration position;

  const PositionChangedEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class DurationChangedEvent extends PlayerBlocEvent {
  final Duration duration;

  const DurationChangedEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}

class BufferedPositionChangedEvent extends PlayerBlocEvent {
  final Duration bufferedPosition;

  const BufferedPositionChangedEvent(this.bufferedPosition);

  @override
  List<Object?> get props => [bufferedPosition];
}

class CurrentIndexChangedEvent extends PlayerBlocEvent {
  final int? index;

  const CurrentIndexChangedEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class AudioErrorEvent extends PlayerBlocEvent {
  final String error;

  const AudioErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

class PlaylistPlaybackStartedEvent extends PlayerBlocEvent {
  final String? sourceId;

  const PlaylistPlaybackStartedEvent({this.sourceId});

  @override
  List<Object?> get props => [sourceId];
}

class InitializeAudioServiceEvent extends PlayerBlocEvent {
  const InitializeAudioServiceEvent();
}

class DisposeAudioServiceEvent extends PlayerBlocEvent {
  const DisposeAudioServiceEvent();
}

class ResetPlayerEvent extends PlayerBlocEvent {
  const ResetPlayerEvent();
}
