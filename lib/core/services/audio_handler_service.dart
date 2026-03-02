import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

/// Handler de audio para notificaciones y controles en pantalla de bloqueo
class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  /// Reproducir canción
  Future<void> playSong(NowPlayingData track) async {
    // Crear MediaItem para la notificación
    final mediaItem = MediaItem(
      id: track.videoId,
      album: track.album.name,
      title: track.title,
      artist: track.artistsNames,
      duration: track.durationSeconds > 0
          ? Duration(seconds: track.durationSeconds)
          : null,
      artUri: track.bestThumbnail != null
          ? Uri.tryParse(track.bestThumbnail!.url)
          : null,
    );

    // Crear AudioSource con tag
    final audioSource = AudioSource.uri(
      Uri.parse(track.streamUrl ?? ''),
      tag: mediaItem,
    );

    await _player.setAudioSource(audioSource);
    await _player.play();

    // Actualizar media item
    this.mediaItem.add(mediaItem);
  }

  /// Play
  @override
  Future<void> play() => _player.play();

  /// Pause
  @override
  Future<void> pause() => _player.pause();

  /// Stop
  @override
  Future<void> stop() => _player.stop();

  /// Seek
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Skip to next
  @override
  Future<void> skipToNext() => _player.seekToNext();

  /// Skip to previous
  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  /// Skip to queue item
  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < _player.sequence.length) {
      await _player.seek(Duration.zero, index: index);
    }
  }

  /// Broadcast state changes
  void _broadcastState() {
    final playing = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex ?? 0,
      ),
    );
  }

  /// Inicializar el handler
  void init() {
    // Escuchar cambios de estado del player
    _player.playbackEventStream.listen((_) => _broadcastState());
    _player.playerStateStream.listen((_) => _broadcastState());
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
    await super.onTaskRemoved();
  }
}
