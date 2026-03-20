import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:music_app/features/player/domain/player_engine.dart';

/// Fake determinista de PlayerEngine para tests.
class FakePlayerEngine implements PlayerEngine {
  final _playerStateController = StreamController<PlayerState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _bufferedController = StreamController<Duration>.broadcast();
  final _currentIndexController = StreamController<int?>.broadcast();

  bool _playing = false;
  int? _currentIndex;

  AudioSource? lastSource;
  int setAudioSourceCallCount = 0;

  @override
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;

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

  void emitPlayerState({
    bool? playing,
    ProcessingState? processing,
  }) {
    _playerStateController.add(
      PlayerState(
        playing ?? _playing,
        processing ?? ProcessingState.ready,
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
    emitPlayerState(playing: false, processing: ProcessingState.idle);
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
  Future<void> addAudioSources(List<AudioSource> sources) async {
    // no-op para fake
  }

  @override
  Future<void> removeAudioSourceAt(int index) async {
    // no-op para fake
  }

  @override
  Future<void> setAudioSource(AudioSource source, {bool preload = false}) async {
    setAudioSourceCallCount++;
    lastSource = source;
    emitPlayerState(processing: ProcessingState.loading);
    // Simular carga determinista.
    emitPlayerState(processing: ProcessingState.ready);
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async {
    // no-op para fake
  }

  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {
    // no-op para fake
  }

  @override
  Future<void> setSpeed(double speed) async {
    // no-op para fake
  }

  @override
  Future<void> setVolume(double volume) async {
    // no-op para fake
  }

  Future<void> dispose() async {
    await _playerStateController.close();
    await _positionController.close();
    await _durationController.close();
    await _bufferedController.close();
    await _currentIndexController.close();
  }
}

