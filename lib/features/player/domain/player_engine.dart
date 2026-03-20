import 'dart:async';

import 'package:just_audio/just_audio.dart';

/// Abstracción del motor de audio.
///
/// Objetivo: poder testear PlayerBloc de forma determinista (con fakes) y
/// aislar a `just_audio` para manejar mejor condiciones de carrera.
abstract interface class PlayerEngine {
  /// Streams principales del motor.
  Stream<PlayerState> get playerStateStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<Duration> get bufferedPositionStream;
  Stream<int?> get currentIndexStream;

  bool get playing;
  int? get currentIndex;

  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position, {int? index});
  Future<void> seekToNext();
  Future<void> seekToPrevious();

  Future<void> addAudioSources(List<AudioSource> sources);
  Future<void> removeAudioSourceAt(int index);

  Future<void> setAudioSource(AudioSource source, {bool preload = false});
  Future<void> setLoopMode(LoopMode mode);
  Future<void> setShuffleModeEnabled(bool enabled);
  Future<void> setSpeed(double speed);
  Future<void> setVolume(double volume);
}

