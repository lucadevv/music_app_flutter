import 'package:just_audio/just_audio.dart';
import 'package:music_app/features/player/domain/player_engine.dart';

class JustAudioPlayerEngine implements PlayerEngine {
  final AudioPlayer _player;

  JustAudioPlayerEngine(this._player);

  @override
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  @override
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  @override
  bool get playing => _player.playing;

  @override
  int? get currentIndex => _player.currentIndex;

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position, {int? index}) => _player.seek(position, index: index);

  @override
  Future<void> seekToNext() => _player.seekToNext();

  @override
  Future<void> seekToPrevious() => _player.seekToPrevious();

  @override
  Future<void> addAudioSources(List<AudioSource> sources) =>
      _player.addAudioSources(sources);

  @override
  Future<void> removeAudioSourceAt(int index) => _player.removeAudioSourceAt(index);

  @override
  Future<void> setAudioSource(AudioSource source, {bool preload = false}) =>
      _player.setAudioSource(source, preload: preload);

  @override
  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);

  @override
  Future<void> setShuffleModeEnabled(bool enabled) =>
      _player.setShuffleModeEnabled(enabled);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);
}

