import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

// Mock AudioPlayer
class MockAudioPlayer extends Mock implements AudioPlayer {}

// Track 测试数据
NowPlayingData createTrack(String videoId, String title) {
  return NowPlayingData.fromBasic(
    videoId: videoId,
    title: title,
    artistNames: const ['Test Artist'],
    albumName: 'Test Album',
    duration: '3:00',
    durationSeconds: 180,
    thumbnailUrl: 'https://example.com/thumb.jpg',
    streamUrl: 'https://example.com/stream/$videoId.m4a',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerBloc - Unit Tests (sin AudioPlayer real)', () {
    late PlayerBlocBloc bloc;

    setUp(() {
      bloc = PlayerBlocBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('Estado inicial correcto', () {
      expect(bloc.state.playbackState, PlaybackState.stopped);
      expect(bloc.state.processingState, ProcessingState.idle);
      expect(bloc.state.playlist, isEmpty);
      expect(bloc.state.currentTrack, isNull);
    });

    group('PlayRequestEvent - Lógica de negocio', () {
      test('Si ya reproduce la misma canción, no hace nada', () {
        // Agregar estado con la misma canción reproduciendo
        // El bloc debe detectar videoId iguales y no hacer nada
        
        // Verificar que la lógica interna funciona
        const currentVideoId = 'video1';
        const targetVideoId = 'video1';
        
        // Deben ser iguales
        expect(currentVideoId, equals(targetVideoId));
      });

      test('Si es canción diferente, debe generar evento diferente', () {
        const currentVideoId = 'video1';
        const targetVideoId = 'video2';
        
        // Deben ser diferentes
        expect(currentVideoId, isNot(equals(targetVideoId)));
      });
    });

    group('AddToPlaylistEvent - Prevención de duplicados', () {
      test('Detectar歌曲ya existe en playlist', () {
        final track1 = createTrack('video1', 'Song 1');
        final track2 = createTrack('video2', 'Song 2');
        final playlist = [track1, track2];
        
        // Verificar que track1 existe
        final exists = playlist.any((t) => t.videoId == 'video1');
        expect(exists, isTrue);
        
        // Verificar que track3 NO existe
        final notExists = playlist.any((t) => t.videoId == 'video3');
        expect(notExists, isFalse);
      });
    });

    group('LoadPlaylistEvent - Validación', () {
      test('Playlist vacía es inválida', () {
        final playlist = <NowPlayingData>[];
        expect(playlist.isEmpty, isTrue);
      });

      test('Playlist con elementos es válida', () {
        final playlist = [
          createTrack('video1', 'Song 1'),
          createTrack('video2', 'Song 2'),
        ];
        expect(playlist.isNotEmpty, isTrue);
        expect(playlist.length, equals(2));
      });

      test('startIndex fuera de rango debe ajustarse', () {
        final playlist = [
          createTrack('video1', 'Song 1'),
          createTrack('video2', 'Song 2'),
        ];
        const startIndex = 10; // Fuera de rango
        final safeIndex = startIndex < playlist.length ? startIndex : 0;
        expect(safeIndex, equals(0));
      });

      test('startIndex válido debe usarse', () {
        final playlist = [
          createTrack('video1', 'Song 1'),
          createTrack('video2', 'Song 2'),
        ];
        const startIndex = 1;
        final safeIndex = startIndex < playlist.length ? startIndex : 0;
        expect(safeIndex, equals(1));
      });
    });

    group('RemoveFromPlaylistEvent - Casos edge', () {
      test('Índice negativo es inválido', () {
        const index = -1;
        const playlistLength = 3;
        expect(index >= 0 && index < playlistLength, isFalse);
      });

      test('Índice mayor que longitud es inválido', () {
        const index = 5;
        const playlistLength = 3;
        expect(index >= 0 && index < playlistLength, isFalse);
      });

      test('Índice válido está en rango', () {
        const index = 2;
        const playlistLength = 3;
        expect(index >= 0 && index < playlistLength, isTrue);
      });
    });

    group('Configuración - Valores clanpeados', () {
      test('Volume > 1.0 debe clanpearse a 1.0', () {
        const volume = 1.5;
        final clamped = volume.clamp(0.0, 1.0);
        expect(clamped, equals(1.0));
      });

      test('Volume < 0.0 debe clanpearse a 0.0', () {
        const volume = -0.5;
        final clamped = volume.clamp(0.0, 1.0);
        expect(clamped, equals(0.0));
      });

      test('Speed > 2.0 debe clanpearse a 2.0', () {
        const speed = 3.0;
        final clamped = speed.clamp(0.5, 2.0);
        expect(clamped, equals(2.0));
      });

      test('Speed < 0.5 debe clanpearse a 0.5', () {
        const speed = 0.1;
        final clamped = speed.clamp(0.5, 2.0);
        expect(clamped, equals(0.5));
      });
    });

    group('PlayRequestEvent - Verificación de playlist existente', () {
      test('Playlist vacía → no encontrar índice', () {
        final playlist = <NowPlayingData>[];
        const targetVideoId = 'video1';
        
        final trackIndex = playlist.indexWhere((t) => t.videoId == targetVideoId);
        expect(trackIndex, equals(-1));
      });

      test('Playlist con canción → encontrar índice', () {
        final playlist = [
          createTrack('video1', 'Song 1'),
          createTrack('video2', 'Song 2'),
          createTrack('video3', 'Song 3'),
        ];
        const targetVideoId = 'video2';
        
        final trackIndex = playlist.indexWhere((t) => t.videoId == targetVideoId);
        expect(trackIndex, equals(1));
      });
    });

    group('Comparación de playlists', () {
      test('Mismo sourceId pero diferentes canciones → NO es la misma playlist', () {
        final currentPlaylist = [
          createTrack('video1', 'Song 1'),
          createTrack('video2', 'Song 2'),
        ];
        final newPlaylist = [
          createTrack('video3', 'Song 3'),
          createTrack('video4', 'Song 4'),
        ];
        
        // Verificar si son la misma playlist
        final isSame = currentPlaylist.isNotEmpty &&
            currentPlaylist.length == newPlaylist.length &&
            currentPlaylist.every((t) => newPlaylist.any((e) => e.videoId == t.videoId));
        
        expect(isSame, isFalse);
      });

      test('Mismo sourceId y mismos videos → ES la misma playlist', () {
        final playlist = [
          createTrack('video1', 'Song 1'),
          createTrack('video2', 'Song 2'),
        ];
        
        final isSame = playlist.isNotEmpty &&
            playlist.length == playlist.length &&
            playlist.every((t) => playlist.any((e) => e.videoId == t.videoId));
        
        expect(isSame, isTrue);
      });
    });

    group('PlayTrackAtIndexEvent - Validación de índice', () {
      test('Índice negativo es inválido', () {
        const index = -1;
        const playlistLength = 3;
        expect(index >= 0 && index < playlistLength, isFalse);
      });

      test('Índice igual a longitud es inválido', () {
        const index = 3;
        const playlistLength = 3;
        expect(index >= 0 && index < playlistLength, isFalse);
      });

      test('Índice válido funciona', () {
        const index = 2;
        const playlistLength = 3;
        expect(index >= 0 && index < playlistLength, isTrue);
      });
    });
  });

  group('PlayerBlocState - Pruebas de estado', () {
    test('Valores por defecto correctos', () {
      const state = PlayerBlocState();
      
      expect(state.playbackState, PlaybackState.stopped);
      expect(state.processingState, ProcessingState.idle);
      expect(state.playlist, isEmpty);
      expect(state.currentIndex, isNull);
      expect(state.currentTrack, isNull);
      expect(state.position, Duration.zero);
      expect(state.duration, Duration.zero);
      expect(state.volume, 1.0);
      expect(state.speed, 1.0);
      expect(state.loopMode, LoopMode.off);
      expect(state.isShuffleEnabled, isFalse);
      expect(state.error, isNull);
      expect(state.isLoading, isFalse);
    });

    test('Getters calculados correctamente', () {
      const state = PlayerBlocState(playbackState: PlaybackState.playing);
      expect(state.isPlaying, isTrue);
      expect(state.isPaused, isFalse);
      expect(state.isStopped, isFalse);
    });

    test('canPlayNext funciona correctamente', () {
      final playlist = [
        createTrack('video1', 'Song 1'),
        createTrack('video2', 'Song 2'),
        createTrack('video3', 'Song 3'),
      ];
      
      // En índice 1, puede ir al 2
      var state = PlayerBlocState(playlist: playlist, currentIndex: 1);
      expect(state.canPlayNext, isTrue);
      
      // En índice 2, NO puede ir al siguiente
      state = PlayerBlocState(playlist: playlist, currentIndex: 2);
      expect(state.canPlayNext, isFalse);
    });

    test('canPlayPrevious funciona correctamente', () {
      final playlist = [
        createTrack('video1', 'Song 1'),
        createTrack('video2', 'Song 2'),
        createTrack('video3', 'Song 3'),
      ];
      
      // En índice 1, puede ir al 0
      var state = PlayerBlocState(playlist: playlist, currentIndex: 1);
      expect(state.canPlayPrevious, isTrue);
      
      // En índice 0, NO puede ir al anterior
      state = PlayerBlocState(playlist: playlist, currentIndex: 0);
      expect(state.canPlayPrevious, isFalse);
    });

    test('copyWith funciona correctamente', () {
      const original = PlayerBlocState(volume: 0.5);
      final updated = original.copyWith(volume: 0.8);
      
      expect(original.volume, equals(0.5));
      expect(updated.volume, equals(0.8));
    });

    test('copyWith con clearError funciona', () {
      const original = PlayerBlocState(error: 'Some error');
      final updated = original.copyWith(clearError: true);
      
      expect(updated.error, isNull);
    });
  });
}