import '../../domain/entities/chart_song.dart';

/// Modelo de datos para ChartSong
class ChartSongModel extends ChartSong {
  const ChartSongModel({
    required super.videoId,
    required super.title,
    required super.artist,
    required super.streamUrl,
    required super.thumbnail,
  });

  factory ChartSongModel.fromJson(Map<String, dynamic> json) {
    return ChartSongModel(
      videoId: json['videoId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      streamUrl: json['stream_url'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'artist': artist,
      'stream_url': streamUrl,
      'thumbnail': thumbnail,
    };
  }
}
