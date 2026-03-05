import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/downloads/domain/repositories/downloads_repository.dart';
import 'package:music_app/features/downloads/domain/use_cases/check_download_status_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/download_song_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/get_downloaded_songs_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/remove_download_use_case.dart';
import 'package:music_app/features/downloads/presentation/cubit/downloads_cubit.dart';

import '../../../../helpers/test_helpers.dart';

class MockDownloadsRepository extends Mock implements DownloadsRepository {}

class MockPlayerBlocBloc extends Mock implements PlayerBlocBloc {}

void main() {
  late DownloadsCubit downloadsCubit;
  late MockDownloadsRepository mockRepository;
  late DownloadSongUseCase downloadSongUseCase;
  late GetDownloadedSongsUseCase getDownloadedSongsUseCase;
  late RemoveDownloadUseCase removeDownloadUseCase;
  late CheckDownloadStatusUseCase checkDownloadStatusUseCase;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockRepository = MockDownloadsRepository();
    final mockPlayerBloc = MockPlayerBlocBloc();
    downloadSongUseCase = DownloadSongUseCase(mockRepository);
    getDownloadedSongsUseCase = GetDownloadedSongsUseCase(mockRepository);
    removeDownloadUseCase = RemoveDownloadUseCase(mockRepository);
    checkDownloadStatusUseCase = CheckDownloadStatusUseCase(mockRepository);
    downloadsCubit = DownloadsCubit(
      downloadSongUseCase,
      getDownloadedSongsUseCase,
      removeDownloadUseCase,
      checkDownloadStatusUseCase,
      mockPlayerBloc,
    );
  });

  tearDown(() {
    downloadsCubit.close();
  });

  group('DownloadsCubit', () {
    test('initial state should be DownloadsState with initial status', () {
      expect(downloadsCubit.state.status, equals(DownloadsStatus.initial));
      expect(downloadsCubit.state.errorMessage, isNull);
      expect(downloadsCubit.state.downloadedSongs, isEmpty);
      expect(downloadsCubit.state.downloadingIds, isEmpty);
      expect(downloadsCubit.state.downloadProgress, isEmpty);
    });

    blocTest<DownloadsCubit, DownloadsState>(
      'should emit [loading, success] when loadDownloads succeeds',
      build: () {
        when(
          () => mockRepository.getDownloadedSongs(),
        ).thenAnswer((_) async => Right(createTestDownloadedSongs()));
        return downloadsCubit;
      },
      act: (cubit) => cubit.loadDownloads(),
      expect: () => [
        isA<DownloadsState>().having(
          (s) => s.status,
          'status',
          DownloadsStatus.loading,
        ),
        isA<DownloadsState>()
            .having((s) => s.status, 'status', DownloadsStatus.success)
            .having(
              (s) => s.downloadedSongs.length,
              'downloadedSongs.length',
              3,
            ),
      ],
    );

    blocTest<DownloadsCubit, DownloadsState>(
      'should emit [loading, failure] when loadDownloads fails',
      build: () {
        when(
          () => mockRepository.getDownloadedSongs(),
        ).thenAnswer((_) async => Left(createTestNetworkException()));
        return downloadsCubit;
      },
      act: (cubit) => cubit.loadDownloads(),
      expect: () => [
        isA<DownloadsState>().having(
          (s) => s.status,
          'status',
          DownloadsStatus.loading,
        ),
        isA<DownloadsState>()
            .having((s) => s.status, 'status', DownloadsStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<DownloadsCubit, DownloadsState>(
      'should handle empty downloads list',
      build: () {
        when(
          () => mockRepository.getDownloadedSongs(),
        ).thenAnswer((_) async => const Right([]));
        return downloadsCubit;
      },
      act: (cubit) => cubit.loadDownloads(),
      expect: () => [
        isA<DownloadsState>().having(
          (s) => s.status,
          'status',
          DownloadsStatus.loading,
        ),
        isA<DownloadsState>()
            .having((s) => s.status, 'status', DownloadsStatus.success)
            .having((s) => s.downloadedSongs, 'downloadedSongs', isEmpty),
      ],
    );

    blocTest<DownloadsCubit, DownloadsState>(
      'should remove song from list when removeDownload succeeds',
      build: () {
        when(
          () => mockRepository.getDownloadedSongs(),
        ).thenAnswer((_) async => Right(createTestDownloadedSongs()));
        when(
          () => mockRepository.removeDownload(any()),
        ).thenAnswer((_) async => const Right(null));
        return downloadsCubit;
      },
      seed: () => DownloadsState(
        status: DownloadsStatus.success,
        downloadedSongs: createTestDownloadedSongs(),
      ),
      act: (cubit) => cubit.removeDownload('downloaded0'),
      expect: () => [
        isA<DownloadsState>().having(
          (s) => s.downloadedSongs.length,
          'downloadedSongs.length',
          2,
        ),
      ],
    );

    blocTest<DownloadsCubit, DownloadsState>(
      'should set error message when removeDownload fails',
      build: () {
        when(
          () => mockRepository.removeDownload(any()),
        ).thenAnswer((_) async => Left(createTestNetworkException()));
        return downloadsCubit;
      },
      seed: () => DownloadsState(
        status: DownloadsStatus.success,
        downloadedSongs: createTestDownloadedSongs(),
      ),
      act: (cubit) => cubit.removeDownload('downloaded0'),
      expect: () => [
        isA<DownloadsState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          isNotNull,
        ),
      ],
    );

    blocTest<DownloadsCubit, DownloadsState>(
      'should clear error when clearError is called',
      build: () => downloadsCubit,
      seed: () => const DownloadsState(
        status: DownloadsStatus.failure,
        errorMessage: 'Some error',
      ),
      act: (cubit) => cubit.clearError(),
      expect: () => [
        isA<DownloadsState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          isNull,
        ),
      ],
    );

    test('isDownloaded should return true when song is downloaded', () async {
      // Arrange
      when(
        () => mockRepository.isDownloaded('existing'),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await downloadsCubit.isDownloaded('existing');

      // Assert
      expect(result, isTrue);
    });

    test(
      'isDownloaded should return false when song is not downloaded',
      () async {
        // Arrange
        when(
          () => mockRepository.isDownloaded('nonexisting'),
        ).thenAnswer((_) async => const Right(false));

        // Act
        final result = await downloadsCubit.isDownloaded('nonexisting');

        // Assert
        expect(result, isFalse);
      },
    );

    test('isDownloaded should return false when error occurs', () async {
      // Arrange
      when(
        () => mockRepository.isDownloaded('videoId'),
      ).thenAnswer((_) async => Left(createTestNetworkException()));

      // Act
      final result = await downloadsCubit.isDownloaded('videoId');

      // Assert
      expect(result, isFalse);
    });

    test('getProgress should return 0.0 for unknown videoId', () {
      // Act
      final progress = downloadsCubit.getProgress('unknown');

      // Assert
      expect(progress, equals(0.0));
    });

    test('isDownloading should return false for unknown videoId', () {
      // Act
      final isDownloading = downloadsCubit.isDownloading('unknown');

      // Assert
      expect(isDownloading, isFalse);
    });

    test('state should have correct computed properties', () {
      // Arrange
      final state = DownloadsState(
        status: DownloadsStatus.success,
        downloadedSongs: createTestDownloadedSongs(),
        downloadingIds: {'downloading1'},
      );

      // Assert
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isTrue);
      expect(state.isFailure, isFalse);
      expect(state.hasDownloads, isTrue);
      expect(state.hasActiveDownloads, isTrue);
    });

    test('state isLoading should be true when status is loading', () {
      final state = DownloadsState(status: DownloadsStatus.loading);
      expect(state.isLoading, isTrue);
    });

    test('state isFailure should be true when status is failure', () {
      final state = DownloadsState(status: DownloadsStatus.failure);
      expect(state.isFailure, isTrue);
    });
  });
}
