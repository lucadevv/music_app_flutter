import 'package:music_app/core/domain/entities/song.dart' as core;
import 'package:music_app/features/search/domain/entities/song.dart' as search;
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/home/domain/entities/chart_song.dart';
import 'package:music_app/features/library/library_service.dart';

/// Entidad para canciones reproducidas recientemente (usada en recently_played)
class RecentSong {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final String duration;
  final int durationSeconds;
  final DateTime? playedAt;

  const RecentSong({
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    required this.duration,
    this.durationSeconds = 0,
    this.playedAt,
  });

  factory RecentSong.fromJson(Map<String, dynamic> json) {
    final durationStr = json['duration'] ?? '0:00';
    int durationSeconds = 0;
    
    try {
      final parts = durationStr.toString().split(':');
      if (parts.length == 2) {
        durationSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }
    } catch (_) {}

    return RecentSong(
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? 'Unknown',
      artist: json['artist'] ?? 'Unknown Artist',
      thumbnail: json['thumbnail'],
      duration: durationStr.toString(),
      durationSeconds: durationSeconds,
    );
  }
}

/// Mappers para convertir entre las diferentes entidades de Song y la entidad centralizada.
///
/// Esta clase proporciona métodos para convertir fácilmente
/// desde las entidades específicas de cada feature hacia la entidad [core.Song] central.
class SongMapper {
  /// Crea una instancia de [core.Song] desde [search.Song] (búsqueda)
  static core.Song fromSearchSong(search.Song song) {
    return core.Song(
      videoId: song.videoId,
      title: song.title,
      artist: song.artists.isNotEmpty ? song.artists.first.name : 'Unknown',
      artistNames: song.artists.map((a) => a.name).toList(),
      album: song.album.name,
      thumbnail: song.thumbnails.isNotEmpty ? song.thumbnails.first.url : null,
      highThumbnail: song.thumbnail?.url ?? song.thumbnails.lastOrNull?.url,
      thumbnails: song.thumbnails
          .map((t) => core.Thumbnail(url: t.url, width: t.width ?? 0, height: t.height ?? 0))
          .toList(),
      streamUrl: song.streamUrl,
      durationSeconds: song.durationSeconds,
      duration: song.duration,
      views: song.views,
      isExplicit: song.isExplicit,
      inLibrary: song.inLibrary,
    );
  }

  /// Crea una instancia de [core.Song] desde [DownloadedSong]
  static core.Song fromDownloadedSong(DownloadedSong song) {
    return core.Song(
      videoId: song.videoId,
      title: song.title,
      artist: song.artist,
      album: song.album,
      thumbnail: song.thumbnail,
      highThumbnail: song.thumbnail,
      localPath: song.localPath,
      durationSeconds: song.duration.inSeconds,
      duration: song.durationFormatted,
      fileSize: song.fileSize,
      downloadedAt: song.downloadedAt,
    );
  }

  /// Crea una instancia de [core.Song] desde [ChartSong]
  static core.Song fromChartSong(ChartSong song) {
    return core.Song(
      videoId: song.videoId,
      title: song.title,
      artist: song.artist,
      thumbnail: song.thumbnail,
      highThumbnail: song.thumbnail,
      streamUrl: song.streamUrl,
    );
  }

  /// Crea una instancia de [core.Song] desde [SongMetadata] (library)
  static core.Song fromSongMetadata(SongMetadata metadata, String videoId) {
    return core.Song(
      videoId: videoId,
      title: metadata.title ?? 'Unknown',
      artist: metadata.artist ?? 'Unknown',
      thumbnail: metadata.thumbnail,
      durationSeconds: metadata.duration ?? 0,
    );
  }

  /// Crea una instancia de [core.Song] desde [FavoriteSong] (library)
  static core.Song fromFavoriteSong(FavoriteSong song) {
    return core.Song(
      videoId: song.videoId,
      title: song.title ?? 'Unknown',
      artist: song.artist ?? 'Unknown',
      thumbnail: song.thumbnail,
      durationSeconds: song.duration ?? 0,
      duration: _formatDuration(song.duration ?? 0),
      inLibrary: true,
    );
  }

  /// Crea una instancia de [core.Song] desde [UserPlaylistSong]
  static core.Song fromUserPlaylistSong(UserPlaylistSong song) {
    return core.Song(
      videoId: song.videoId,
      title: song.title ?? 'Unknown',
      artist: song.artist ?? 'Unknown',
      thumbnail: song.thumbnail,
      durationSeconds: song.duration ?? 0,
      duration: _formatDuration(song.duration ?? 0),
    );
  }

  /// Crea una instancia de [core.Song] desde [RecentSong] (recently played)
  static core.Song fromRecentSong(RecentSong song) {
    return core.Song(
      videoId: song.videoId,
      title: song.title ?? 'Unknown',
      artist: song.artist ?? 'Unknown',
      thumbnail: song.thumbnail,
      durationSeconds: song.durationSeconds,
      duration: _formatDuration(song.durationSeconds),
    );
  }

  /// Convierte una lista de [search.Song] a [core.Song]
  static List<core.Song> fromSearchSongList(List<search.Song> songs) {
    return songs.map(fromSearchSong).toList();
  }

  /// Convierte una lista de [DownloadedSong] a [core.Song]
  static List<core.Song> fromDownloadedSongList(List<DownloadedSong> songs) {
    return songs.map(fromDownloadedSong).toList();
  }

  /// Convierte una lista de [FavoriteSong] a [core.Song]
  static List<core.Song> fromFavoriteSongList(List<FavoriteSong> songs) {
    return songs.map(fromFavoriteSong).toList();
  }

  /// Convierte una lista de [RecentSong] a [core.Song]
  static List<core.Song> fromRecentSongList(List<RecentSong> songs) {
    return songs.map(fromRecentSong).toList();
  }
}

/// Helper para formatear duración
String _formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}';
}
