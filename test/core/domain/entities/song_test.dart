import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/core/domain/entities/song.dart';

void main() {
  group('Song Entity', () {
    test('should create a valid Song instance', () {
      const song = Song(
        videoId: 'test123',
        title: 'Test Song',
        artist: 'Test Artist',
        durationSeconds: 180,
        duration: '3:00',
      );

      expect(song.videoId, 'test123');
      expect(song.title, 'Test Song');
      expect(song.artist, 'Test Artist');
      expect(song.durationSeconds, 180);
      expect(song.duration, '3:00');
    });

    test('should format duration correctly', () {
      const song = Song(
        videoId: 'test',
        title: 'Test',
        artist: 'Artist',
        durationSeconds: 185,
      );

      expect(song.durationFormatted, '3:05');
    });

    test('should return bestThumbnail correctly', () {
      const songWithHigh = Song(
        videoId: 'test',
        title: 'Test',
        artist: 'Artist',
        highThumbnail: 'https://high.url',
        thumbnail: 'https://low.url',
      );
      expect(songWithHigh.bestThumbnail, 'https://high.url');

      const songWithOnlyThumbnail = Song(
        videoId: 'test',
        title: 'Test',
        artist: 'Artist',
        thumbnail: 'https://low.url',
      );
      expect(songWithOnlyThumbnail.bestThumbnail, 'https://low.url');

      const songWithThumbnails = Song(
        videoId: 'test',
        title: 'Test',
        artist: 'Artist',
        thumbnails: [
          Thumbnail(url: 'https://thumb1.url', width: 100, height: 100),
          Thumbnail(url: 'https://thumb2.url', width: 300, height: 300),
        ],
      );
      expect(songWithThumbnails.bestThumbnail, 'https://thumb2.url');
    });

    test('canPlay should return true when streamUrl exists', () {
      const song = Song(
        videoId: 'test',
        title: 'Test',
        artist: 'Artist',
        streamUrl: 'https://stream.url',
      );
      expect(song.canPlay, true);
    });

    test('canPlay should return false when streamUrl is null', () {
      const song = Song(
        videoId: 'test',
        title: 'Test',
        artist: 'Artist',
      );
      expect(song.canPlay, false);
    });

    test('isDownloaded should return true when localPath exists', () {
      const song = Song(
        videoId: 'test',
        title: 'Test',
        artist: 'Artist',
        localPath: '/path/to/file.mp3',
      );
      expect(song.isDownloaded, true);
    });

    test('copyWith should create new instance with updated values', () {
      const original = Song(
        videoId: 'test',
        title: 'Original',
        artist: 'Artist',
      );

      final copied = original.copyWith(title: 'Updated');

      expect(copied.title, 'Updated');
      expect(copied.videoId, original.videoId);
      expect(copied.artist, original.artist);
    });
  });

  group('Thumbnail Entity', () {
    test('should create valid Thumbnail instance', () {
      const thumb = Thumbnail(
        url: 'https://example.com/thumb.jpg',
        width: 300,
        height: 300,
      );

      expect(thumb.url, 'https://example.com/thumb.jpg');
      expect(thumb.width, 300);
      expect(thumb.height, 300);
    });

    test('should support equality', () {
      const thumb1 = Thumbnail(url: 'url', width: 100, height: 100);
      const thumb2 = Thumbnail(url: 'url', width: 100, height: 100);

      expect(thumb1, equals(thumb2));
    });
  });
}
