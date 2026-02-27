import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('PlayerBlocEvent', () {
    group('PlayEvent', () {
      test('should support value equality', () {
        expect(const PlayEvent(), equals(const PlayEvent()));
      });

      test('props should be empty', () {
        expect(const PlayEvent().props, isEmpty);
      });
    });

    group('PauseEvent', () {
      test('should support value equality', () {
        expect(const PauseEvent(), equals(const PauseEvent()));
      });

      test('props should be empty', () {
        expect(const PauseEvent().props, isEmpty);
      });
    });

    group('StopEvent', () {
      test('should support value equality', () {
        expect(const StopEvent(), equals(const StopEvent()));
      });

      test('props should be empty', () {
        expect(const StopEvent().props, isEmpty);
      });
    });

    group('PlayPauseToggleEvent', () {
      test('should support value equality', () {
        expect(
          const PlayPauseToggleEvent(),
          equals(const PlayPauseToggleEvent()),
        );
      });

      test('props should be empty', () {
        expect(const PlayPauseToggleEvent().props, isEmpty);
      });
    });

    group('NextTrackEvent', () {
      test('should support value equality', () {
        expect(const NextTrackEvent(), equals(const NextTrackEvent()));
      });

      test('props should be empty', () {
        expect(const NextTrackEvent().props, isEmpty);
      });
    });

    group('PreviousTrackEvent', () {
      test('should support value equality', () {
        expect(const PreviousTrackEvent(), equals(const PreviousTrackEvent()));
      });

      test('props should be empty', () {
        expect(const PreviousTrackEvent().props, isEmpty);
      });
    });

    group('SeekEvent', () {
      test('should support value equality', () {
        const duration = Duration(seconds: 30);
        expect(const SeekEvent(duration), equals(const SeekEvent(duration)));
      });

      test('props should contain position', () {
        const duration = Duration(seconds: 30);
        expect(const SeekEvent(duration).props, contains(duration));
      });
    });

    group('LoadTrackEvent', () {
      test('should support value equality', () {
        final track = createTestNowPlayingData();
        expect(LoadTrackEvent(track), equals(LoadTrackEvent(track)));
      });

      test('props should contain track', () {
        final track = createTestNowPlayingData();
        expect(LoadTrackEvent(track).props, contains(track));
      });
    });

    group('LoadPlaylistEvent', () {
      test('should support value equality', () {
        final playlist = createTestNowPlayingList();
        expect(
          LoadPlaylistEvent(playlist: playlist, startIndex: 0),
          equals(LoadPlaylistEvent(playlist: playlist, startIndex: 0)),
        );
      });

      test('props should contain playlist and startIndex', () {
        final playlist = createTestNowPlayingList();
        final event = LoadPlaylistEvent(playlist: playlist, startIndex: 1);
        expect(event.props, contains(playlist));
        expect(event.props, contains(1));
      });
    });

    group('PlayTrackAtIndexEvent', () {
      test('should support value equality', () {
        expect(const PlayTrackAtIndexEvent(2), equals(const PlayTrackAtIndexEvent(2)));
      });

      test('props should contain index', () {
        expect(const PlayTrackAtIndexEvent(2).props, contains(2));
      });
    });

    group('AddToPlaylistEvent', () {
      test('should support value equality', () {
        final track = createTestNowPlayingData();
        expect(AddToPlaylistEvent(track), equals(AddToPlaylistEvent(track)));
      });

      test('props should contain track', () {
        final track = createTestNowPlayingData();
        expect(AddToPlaylistEvent(track).props, contains(track));
      });
    });

    group('RemoveFromPlaylistEvent', () {
      test('should support value equality', () {
        expect(const RemoveFromPlaylistEvent(1), equals(const RemoveFromPlaylistEvent(1)));
      });

      test('props should contain index', () {
        expect(const RemoveFromPlaylistEvent(1).props, contains(1));
      });
    });

    group('SetVolumeEvent', () {
      test('should support value equality', () {
        expect(const SetVolumeEvent(0.5), equals(const SetVolumeEvent(0.5)));
      });

      test('props should contain volume', () {
        expect(const SetVolumeEvent(0.5).props, contains(0.5));
      });
    });

    group('SetSpeedEvent', () {
      test('should support value equality', () {
        expect(const SetSpeedEvent(1.5), equals(const SetSpeedEvent(1.5)));
      });

      test('props should contain speed', () {
        expect(const SetSpeedEvent(1.5).props, contains(1.5));
      });
    });

    group('SetLoopModeEvent', () {
      test('should support value equality', () {
        expect(
          const SetLoopModeEvent(LoopMode.one),
          equals(const SetLoopModeEvent(LoopMode.one)),
        );
      });

      test('props should contain loopMode', () {
        expect(const SetLoopModeEvent(LoopMode.one).props, contains(LoopMode.one));
      });
    });

    group('ToggleShuffleEvent', () {
      test('should support value equality', () {
        expect(const ToggleShuffleEvent(), equals(const ToggleShuffleEvent()));
      });

      test('props should be empty', () {
        expect(const ToggleShuffleEvent().props, isEmpty);
      });
    });

    group('AudioErrorEvent', () {
      test('should support value equality', () {
        expect(
          const AudioErrorEvent('Error message'),
          equals(const AudioErrorEvent('Error message')),
        );
      });

      test('props should contain error', () {
        expect(const AudioErrorEvent('Error message').props, contains('Error message'));
      });
    });
  });

  group('PlayerBlocState', () {
    group('PlayerBlocInitial', () {
      test('should support value equality', () {
        expect(const PlayerBlocInitial(), equals(const PlayerBlocInitial()));
      });

      test('props should be empty', () {
        expect(const PlayerBlocInitial().props, isEmpty);
      });
    });

    group('PlayerBlocLoaded', () {
      test('should have correct default values', () {
        const state = PlayerBlocLoaded();
        expect(state.playbackState, equals(PlaybackState.stopped));
        expect(state.processingState, equals(ProcessingState.idle));
        expect(state.connectionState, equals(AudioConnectionState.disconnected));
        expect(state.playlist, isEmpty);
        expect(state.currentIndex, isNull);
        expect(state.currentTrack, isNull);
        expect(state.position, equals(Duration.zero));
        expect(state.duration, equals(Duration.zero));
        expect(state.volume, equals(1.0));
        expect(state.speed, equals(1.0));
        expect(state.loopMode, equals(LoopMode.off));
        expect(state.isShuffleEnabled, isFalse);
        expect(state.error, isNull);
        expect(state.isLoading, isFalse);
      });

      test('isPlaying should be true when playbackState is playing', () {
        const state = PlayerBlocLoaded(playbackState: PlaybackState.playing);
        expect(state.isPlaying, isTrue);
        expect(state.isPaused, isFalse);
        expect(state.isStopped, isFalse);
      });

      test('isPaused should be true when playbackState is paused', () {
        const state = PlayerBlocLoaded(playbackState: PlaybackState.paused);
        expect(state.isPaused, isTrue);
        expect(state.isPlaying, isFalse);
        expect(state.isStopped, isFalse);
      });

      test('isStopped should be true when playbackState is stopped', () {
        const state = PlayerBlocLoaded(playbackState: PlaybackState.stopped);
        expect(state.isStopped, isTrue);
        expect(state.isPlaying, isFalse);
        expect(state.isPaused, isFalse);
      });

      test('hasError should be true when error is not null', () {
        const state = PlayerBlocLoaded(error: 'Some error');
        expect(state.hasError, isTrue);
      });

      test('hasError should be false when error is null', () {
        const state = PlayerBlocLoaded();
        expect(state.hasError, isFalse);
      });

      test('hasPlaylist should be true when playlist is not empty', () {
        final state = PlayerBlocLoaded(playlist: createTestNowPlayingList());
        expect(state.hasPlaylist, isTrue);
      });

      test('hasPlaylist should be false when playlist is empty', () {
        const state = PlayerBlocLoaded();
        expect(state.hasPlaylist, isFalse);
      });

      test('hasCurrentTrack should be true when currentTrack is not null', () {
        final state = PlayerBlocLoaded(currentTrack: createTestNowPlayingData());
        expect(state.hasCurrentTrack, isTrue);
      });

      test('hasCurrentTrack should be false when currentTrack is null', () {
        const state = PlayerBlocLoaded();
        expect(state.hasCurrentTrack, isFalse);
      });

      test('canPlayNext should be true when not at end of playlist', () {
        final playlist = createTestNowPlayingList(count: 3);
        final state = PlayerBlocLoaded(playlist: playlist, currentIndex: 1);
        expect(state.canPlayNext, isTrue);
      });

      test('canPlayNext should be false when at end of playlist', () {
        final playlist = createTestNowPlayingList(count: 3);
        final state = PlayerBlocLoaded(playlist: playlist, currentIndex: 2);
        expect(state.canPlayNext, isFalse);
      });

      test('canPlayPrevious should be true when not at start of playlist', () {
        final playlist = createTestNowPlayingList(count: 3);
        final state = PlayerBlocLoaded(playlist: playlist, currentIndex: 1);
        expect(state.canPlayPrevious, isTrue);
      });

      test('canPlayPrevious should be false when at start of playlist', () {
        final playlist = createTestNowPlayingList(count: 3);
        final state = PlayerBlocLoaded(playlist: playlist, currentIndex: 0);
        expect(state.canPlayPrevious, isFalse);
      });

      test('progress should return correct value', () {
        const state = PlayerBlocLoaded(
          position: Duration(seconds: 30),
          duration: Duration(minutes: 2),
        );
        // 30 seconds / 120 seconds = 0.25
        expect(state.progress, closeTo(0.25, 0.01));
      });

      test('progress should return 0.0 when duration is zero', () {
        const state = PlayerBlocLoaded(
          position: Duration(seconds: 30),
          duration: Duration.zero,
        );
        expect(state.progress, equals(0.0));
      });

      test('bufferedProgress should return correct value', () {
        const state = PlayerBlocLoaded(
          bufferedPosition: Duration(seconds: 60),
          duration: Duration(minutes: 2),
        );
        // 60 seconds / 120 seconds = 0.5
        expect(state.bufferedProgress, closeTo(0.5, 0.01));
      });

      test('copyWith should create new instance with updated values', () {
        const original = PlayerBlocLoaded(volume: 0.5);
        final updated = original.copyWith(volume: 0.8);
        expect(original.volume, equals(0.5));
        expect(updated.volume, equals(0.8));
      });

      test('copyWith with clearError should set error to null', () {
        const original = PlayerBlocLoaded(error: 'Some error');
        final updated = original.copyWith(clearError: true);
        expect(updated.error, isNull);
      });

      test('copyWith with clearCurrentTrack should set currentTrack to null', () {
        final original = PlayerBlocLoaded(currentTrack: createTestNowPlayingData());
        final updated = original.copyWith(clearCurrentTrack: true);
        expect(updated.currentTrack, isNull);
      });
    });
  });

  group('PlaybackState enum', () {
    test('should have three values', () {
      expect(PlaybackState.values.length, equals(3));
      expect(PlaybackState.values, contains(PlaybackState.stopped));
      expect(PlaybackState.values, contains(PlaybackState.playing));
      expect(PlaybackState.values, contains(PlaybackState.paused));
    });
  });

  group('AudioConnectionState enum', () {
    test('should have three values', () {
      expect(AudioConnectionState.values.length, equals(3));
      expect(AudioConnectionState.values, contains(AudioConnectionState.connected));
      expect(AudioConnectionState.values, contains(AudioConnectionState.connecting));
      expect(AudioConnectionState.values, contains(AudioConnectionState.disconnected));
    });
  });
}
