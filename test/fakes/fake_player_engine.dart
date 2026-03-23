import 'dart:async';

import 'package:music_app/features/player/domain/player_engine.dart';
import 'package:music_app/features/player/domain/types/player_types.dart';

class FakePlayerEngine implements PlayerEngine {
  final _playerStateController = StreamController<PlayerStateInfo>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _bufferedController = StreamController<Duration>.broadcast();
  final _currentIndexController = StreamController<int?>.broadcast();

  bool _playing = false;
  int? _currentIndex;

  AudioSourceConfig? lastSource;
  int setAudioSourceCallCount = 0;

  @override
  Stream<PlayerStateInfo> get playerStateStream =>
      _playerStateController.stream;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Stream<Duration> get bufferedPositionStream => _bufferedController.stream;

  @override
  Stream<int?> get currentIndexStream => _currentIndexController.stream;

  @override
  bool get playing => _playing;

  @override
  int? get currentIndex => _currentIndex;

  void emitPlayerState({bool? playing, ProcessingStateType? processing}) {
    _playerStateController.add(
      PlayerStateInfo(
        isPlaying: playing ?? _playing,
        processingState: processing ?? ProcessingStateType.ready,
      ),
    );
  }

  void emitPosition(Duration pos) {
    _positionController.add(pos);
  }

  void emitDuration(Duration? dur) {
    _durationController.add(dur);
  }

  void emitBuffered(Duration buf) {
    _bufferedController.add(buf);
  }

  void emitCurrentIndex(int? idx) {
    _currentIndex = idx;
    _currentIndexController.add(idx);
  }

  @override
  Future<void> play() async {
    _playing = true;
    emitPlayerState(playing: true);
  }

  @override
  Future<void> pause() async {
    _playing = false;
    emitPlayerState(playing: false);
  }

  @override
  Future<void> stop() async {
    _playing = false;
    emitPlayerState(playing: false, processing: ProcessingStateType.idle);
    emitPosition(Duration.zero);
  }

  @override
  Future<void> seek(Duration position, {int? index}) async {
    if (index != null) {
      emitCurrentIndex(index);
    }
    emitPosition(position);
  }

  @override
  Future<void> seekToNext() async {
    if (_currentIndex == null) return;
    emitCurrentIndex(_currentIndex! + 1);
    emitPosition(Duration.zero);
  }

  @override
  Future<void> seekToPrevious() async {
    if (_currentIndex == null) return;
    emitCurrentIndex((_currentIndex! - 1).clamp(0, 1 << 30));
    emitPosition(Duration.zero);
  }

  @override
  Future<void> addAudioSources(List<AudioSourceConfig> sources) async {}

  @override
  Future<void> removeAudioSourceAt(int index) async {}

  @override
  Future<void> setAudioSource(
    AudioSourceConfig source, {
    bool preload = false,
  }) async {
    setAudioSourceCallCount++;
    lastSource = source;
    emitPlayerState(processing: ProcessingStateType.loading);
    emitPlayerState(processing: ProcessingStateType.ready);
  }

  @override
  Future<void> setAudioSources(
    List<AudioSourceConfig> sources, {
    bool preload = false,
    int? initialIndex,
  }) async {
    if (sources.isNotEmpty) {
      lastSource = sources.first;
    }
    setAudioSourceCallCount++;
    emitPlayerState(processing: ProcessingStateType.loading);
    emitPlayerState(processing: ProcessingStateType.ready);
  }

  @override
  Future<void> setLoopMode(LoopModeType mode) async {}

  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> setVolume(double volume) async {}

  Future<void> dispose() async {
    await _playerStateController.close();
    await _positionController.close();
    await _durationController.close();
    await _bufferedController.close();
    await _currentIndexController.close();
  }
}
