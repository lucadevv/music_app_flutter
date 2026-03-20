import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';


import '../../../../fakes/fake_player_engine.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('PlayerBlocBloc - last tap wins', () {
    late FakePlayerEngine engine;

    setUp(() {
      engine = FakePlayerEngine();
    });

    tearDown(() async {
      await engine.dispose();
    });

    blocTest<PlayerBlocBloc, PlayerBlocState>(
      'si llegan 2 LoadTrackEvent seguidos, termina con el último track',
      build: () => PlayerBlocBloc(engine: engine),
      act: (bloc) {
        final t1 = createTestNowPlayingData(videoId: 'v1', title: 'Song 1');
        final t2 = createTestNowPlayingData(videoId: 'v2', title: 'Song 2');

        bloc.add(LoadTrackEvent(t1, sourceId: 'single:v1'));
        bloc.add(LoadTrackEvent(t2, sourceId: 'single:v2'));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.currentTrack?.videoId, equals('v2'));
        expect(bloc.state.sourceId, equals('single:v2'));
      },
    );

    blocTest<PlayerBlocBloc, PlayerBlocState>(
      'eventos duplicados del mismo track no deben spamear setAudioSource',
      build: () => PlayerBlocBloc(engine: engine),
      act: (bloc) {
        final t1 = createTestNowPlayingData(videoId: 'v1', title: 'Song 1');
        bloc.add(LoadTrackEvent(t1, sourceId: 'single:v1'));
        bloc.add(LoadTrackEvent(t1, sourceId: 'single:v1'));
      },
      wait: const Duration(milliseconds: 10),
      verify: (_) {
        expect(engine.setAudioSourceCallCount, equals(1));
      },
    );
  });
}

