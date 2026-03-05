part of 'player_bloc_bloc.dart';

/// Eventos del reproductor
///
/// SOLID: Open/Closed Principle (OCP)
/// Fácil de extender con nuevos eventos sin modificar código existente
sealed class PlayerBlocEvent extends Equatable {
  const PlayerBlocEvent();

  @override
  List<Object?> get props => [];
}

// ========== Eventos de control básico ==========

/// Reproducir la canción actual
class PlayEvent extends PlayerBlocEvent {
  const PlayEvent();
}

/// Pausar la reproducción
class PauseEvent extends PlayerBlocEvent {
  const PauseEvent();
}

/// Detener la reproducción
class StopEvent extends PlayerBlocEvent {
  const StopEvent();
}

/// Alternar entre reproducir y pausar
class PlayPauseToggleEvent extends PlayerBlocEvent {
  const PlayPauseToggleEvent();
}

// ========== Eventos de navegación ==========

/// Reproducir siguiente canción
class NextTrackEvent extends PlayerBlocEvent {
  const NextTrackEvent();
}

/// Reproducir canción anterior
class PreviousTrackEvent extends PlayerBlocEvent {
  const PreviousTrackEvent();
}

/// Buscar a una posición específica
class SeekEvent extends PlayerBlocEvent {
  final Duration position;

  const SeekEvent(this.position);

  @override
  List<Object?> get props => [position];
}

// ========== Eventos de playlist ==========

/// Cargar una sola canción
class LoadTrackEvent extends PlayerBlocEvent {
  final NowPlayingData track;

  const LoadTrackEvent(this.track);

  @override
  List<Object?> get props => [track];
}

/// Cargar una playlist
class LoadPlaylistEvent extends PlayerBlocEvent {
  final List<NowPlayingData> playlist;
  final int? startIndex;

  const LoadPlaylistEvent({required this.playlist, this.startIndex});

  @override
  List<Object?> get props => [playlist, startIndex];
}

/// Reproducir canción en un índice específico
class PlayTrackAtIndexEvent extends PlayerBlocEvent {
  final int index;

  const PlayTrackAtIndexEvent(this.index);

  @override
  List<Object?> get props => [index];
}

/// Agregar canción a la playlist
class AddToPlaylistEvent extends PlayerBlocEvent {
  final NowPlayingData track;

  const AddToPlaylistEvent(this.track);

  @override
  List<Object?> get props => [track];
}

/// Agregar múltiples canciones a la playlist
class AddMultipleToPlaylistEvent extends PlayerBlocEvent {
  final List<NowPlayingData> tracks;

  const AddMultipleToPlaylistEvent(this.tracks);

  @override
  List<Object?> get props => [tracks];
}

/// Cargar una canción con URL ya resuelta (para playlist loading)


/// Remover canción de la playlist
class RemoveFromPlaylistEvent extends PlayerBlocEvent {
  final int index;

  const RemoveFromPlaylistEvent(this.index);

  @override
  List<Object?> get props => [index];
}

// ========== Eventos de configuración ==========

/// Cambiar volumen
class SetVolumeEvent extends PlayerBlocEvent {
  final double volume;

  const SetVolumeEvent(this.volume);

  @override
  List<Object?> get props => [volume];
}

/// Cambiar velocidad de reproducción
class SetSpeedEvent extends PlayerBlocEvent {
  final double speed;

  const SetSpeedEvent(this.speed);

  @override
  List<Object?> get props => [speed];
}

/// Cambiar modo de repetición
class SetLoopModeEvent extends PlayerBlocEvent {
  final LoopMode loopMode;

  const SetLoopModeEvent(this.loopMode);

  @override
  List<Object?> get props => [loopMode];
}

/// Alternar modo shuffle
class ToggleShuffleEvent extends PlayerBlocEvent {
  const ToggleShuffleEvent();
}

// ========== Eventos de estado del reproductor ==========

/// Estado del reproductor cambió
class AudioPlayerStateChangedEvent extends PlayerBlocEvent {
  final PlayerState playerState;

  const AudioPlayerStateChangedEvent(this.playerState);

  @override
  List<Object?> get props => [playerState.playing, playerState.processingState];
}

/// Posición de reproducción cambió
class PositionChangedEvent extends PlayerBlocEvent {
  final Duration position;

  const PositionChangedEvent(this.position);

  @override
  List<Object?> get props => [position];
}

/// Duración de la canción cambió
class DurationChangedEvent extends PlayerBlocEvent {
  final Duration duration;

  const DurationChangedEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// Posición bufferizada cambió
class BufferedPositionChangedEvent extends PlayerBlocEvent {
  final Duration bufferedPosition;

  const BufferedPositionChangedEvent(this.bufferedPosition);

  @override
  List<Object?> get props => [bufferedPosition];
}

/// Índice actual de la playlist cambió
class CurrentIndexChangedEvent extends PlayerBlocEvent {
  final int? index;

  const CurrentIndexChangedEvent(this.index);

  @override
  List<Object?> get props => [index];
}

/// Error en el reproductor
class AudioErrorEvent extends PlayerBlocEvent {
  final String error;

  const AudioErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

// ========== Eventos de AudioService ==========

/// Inicializar AudioService
class InitializeAudioServiceEvent extends PlayerBlocEvent {
  const InitializeAudioServiceEvent();
}

/// Cerrar AudioService
class DisposeAudioServiceEvent extends PlayerBlocEvent {
  const DisposeAudioServiceEvent();
}

/// Resetear el player al estado inicial (para cuando se reproduce una canción individual)
class ResetPlayerEvent extends PlayerBlocEvent {
  const ResetPlayerEvent();
}
