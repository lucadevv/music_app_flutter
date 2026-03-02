import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/downloads/domain/repositories/downloads_repository.dart';
import 'package:music_app/features/downloads/domain/use_cases/download_song_use_case.dart';

import '../../../../helpers/test_helpers.dart';

class MockDownloadsRepository extends Mock implements DownloadsRepository {}

void main() {
  late DownloadSongUseCase useCase;
  late MockDownloadsRepository mockRepository;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockRepository = MockDownloadsRepository();
    useCase = DownloadSongUseCase(mockRepository);
  });

  group('DownloadSongUseCase', () {
    test('should return DownloadedSong on successful download', () async {
      // Arrange
      final expectedSong = createTestDownloadedSong();
      when(
        () => mockRepository.downloadSong(
          videoId: any(named: 'videoId'),
          title: any(named: 'title'),
          artist: any(named: 'artist'),
          album: any(named: 'album'),
          thumbnail: any(named: 'thumbnail'),
          streamUrl: any(named: 'streamUrl'),
          duration: any(named: 'duration'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => Right(expectedSong));

      // Act
      final params = DownloadParams(
        videoId: 'video123',
        title: 'Test Song',
        artist: 'Test Artist',
        streamUrl: 'https://example.com/stream.m4a',
        duration: const Duration(minutes: 3),
        onProgress: (_) {},
      );
      final (error, song) = await useCase(params);

      // Assert
      expect(error, isNull);
      expect(song, isNotNull);
      expect(song!.videoId, equals('downloaded123'));
    });

    test('should return error when download fails', () async {
      // Arrange
      final exception = createTestNetworkException('Download failed');
      when(
        () => mockRepository.downloadSong(
          videoId: any(named: 'videoId'),
          title: any(named: 'title'),
          artist: any(named: 'artist'),
          album: any(named: 'album'),
          thumbnail: any(named: 'thumbnail'),
          streamUrl: any(named: 'streamUrl'),
          duration: any(named: 'duration'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => Left(exception));

      // Act
      final params = DownloadParams(
        videoId: 'video123',
        title: 'Test Song',
        artist: 'Test Artist',
        streamUrl: 'https://example.com/stream.m4a',
        duration: const Duration(minutes: 3),
        onProgress: (_) {},
      );
      final (error, song) = await useCase(params);

      // Assert
      expect(error, isNotNull);
      expect(error!.message, equals('Download failed'));
      expect(song, isNull);
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      final expectedSong = createTestDownloadedSong();
      when(
        () => mockRepository.downloadSong(
          videoId: any(named: 'videoId'),
          title: any(named: 'title'),
          artist: any(named: 'artist'),
          album: any(named: 'album'),
          thumbnail: any(named: 'thumbnail'),
          streamUrl: any(named: 'streamUrl'),
          duration: any(named: 'duration'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => Right(expectedSong));

      // Act
      final params = DownloadParams(
        videoId: 'video123',
        title: 'Test Song',
        artist: 'Test Artist',
        album: 'Test Album',
        thumbnail: 'https://example.com/thumb.jpg',
        streamUrl: 'https://example.com/stream.m4a',
        duration: const Duration(minutes: 3, seconds: 30),
        onProgress: (_) {},
      );
      await useCase(params);

      // Assert
      verify(
        () => mockRepository.downloadSong(
          videoId: 'video123',
          title: 'Test Song',
          artist: 'Test Artist',
          album: 'Test Album',
          thumbnail: 'https://example.com/thumb.jpg',
          streamUrl: 'https://example.com/stream.m4a',
          duration: const Duration(minutes: 3, seconds: 30),
          onProgress: any(named: 'onProgress'),
        ),
      ).called(1);
    });

    test('should handle ServerException', () async {
      // Arrange
      final exception = createTestServerException('Storage full');
      when(
        () => mockRepository.downloadSong(
          videoId: any(named: 'videoId'),
          title: any(named: 'title'),
          artist: any(named: 'artist'),
          album: any(named: 'album'),
          thumbnail: any(named: 'thumbnail'),
          streamUrl: any(named: 'streamUrl'),
          duration: any(named: 'duration'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => Left(exception));

      // Act
      final params = DownloadParams(
        videoId: 'video123',
        title: 'Test Song',
        artist: 'Test Artist',
        streamUrl: 'https://example.com/stream.m4a',
        duration: const Duration(minutes: 3),
        onProgress: (_) {},
      );
      final (error, _) = await useCase(params);

      // Assert
      expect(error, isA<ServerException>());
      expect(error!.message, equals('Storage full'));
    });
  });
}
