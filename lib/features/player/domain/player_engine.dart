import 'dart:async';

import 'package:music_app/features/player/domain/types/player_types.dart';

abstract interface class PlayerEngine {
  Stream<PlayerStateInfo> get playerStateStream;
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

  Future<void> addAudioSources(List<AudioSourceConfig> sources);
  Future<void> removeAudioSourceAt(int index);

  Future<void> setAudioSource(AudioSourceConfig source, {bool preload = false});
  Future<void> setAudioSources(
    List<AudioSourceConfig> sources, {
    bool preload = false,
    int? initialIndex,
  });
  Future<void> setLoopMode(LoopModeType mode);
  Future<void> setShuffleModeEnabled(bool enabled);
  Future<void> setSpeed(double speed);
  Future<void> setVolume(double volume);
}
