// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:music_app/features/player/domain/player_engine.dart';
import 'package:music_app/features/player/domain/types/player_types.dart';

class JustAudioPlayerEngine implements PlayerEngine {
  final AudioPlayer _player;

  JustAudioPlayerEngine(this._player);

  @override
  Stream<PlayerStateInfo> get playerStateStream =>
      _player.playerStateStream.map(_mapPlayerState);

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
  Future<void> seek(Duration position, {int? index}) =>
      _player.seek(position, index: index);

  @override
  Future<void> seekToNext() => _player.seekToNext();

  @override
  Future<void> seekToPrevious() => _player.seekToPrevious();

  @override
  Future<void> addAudioSources(List<AudioSourceConfig> sources) =>
      _player.addAudioSources(sources.map(_toAudioSource).toList());

  @override
  Future<void> removeAudioSourceAt(int index) =>
      _player.removeAudioSourceAt(index);

  @override
  Future<void> setAudioSource(
    AudioSourceConfig source, {
    bool preload = false,
  }) {
    final concatenating = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: [_toAudioSource(source)],
    );
    return _player.setAudioSource(concatenating, preload: preload);
  }

  @override
  Future<void> setAudioSources(
    List<AudioSourceConfig> sources, {
    bool preload = false,
    int? initialIndex,
  }) async {
    final concatenating = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: sources.map(_toAudioSource).toList(),
    );
    await _player.setAudioSource(concatenating, preload: preload);
    if (initialIndex != null && initialIndex > 0) {
      await _player.seek(Duration.zero, index: initialIndex);
    }
  }

  @override
  Future<void> setLoopMode(LoopModeType mode) =>
      _player.setLoopMode(_mapLoopMode(mode));

  @override
  Future<void> setShuffleModeEnabled(bool enabled) =>
      _player.setShuffleModeEnabled(enabled);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  AudioSource _toAudioSource(AudioSourceConfig config) {
    return AudioSource.uri(Uri.parse(config.url), tag: config.mediaItem);
  }

  PlayerStateInfo _mapPlayerState(PlayerState state) {
    return PlayerStateInfo(
      isPlaying: state.playing,
      processingState: _mapProcessingState(state.processingState),
    );
  }

  ProcessingStateType _mapProcessingState(ProcessingState state) {
    return switch (state) {
      ProcessingState.idle => ProcessingStateType.idle,
      ProcessingState.loading => ProcessingStateType.loading,
      ProcessingState.buffering => ProcessingStateType.buffering,
      ProcessingState.ready => ProcessingStateType.ready,
      ProcessingState.completed => ProcessingStateType.completed,
    };
  }

  LoopMode _mapLoopMode(LoopModeType mode) {
    return switch (mode) {
      LoopModeType.off => LoopMode.off,
      LoopModeType.one => LoopMode.one,
      LoopModeType.all => LoopMode.all,
    };
  }
}
