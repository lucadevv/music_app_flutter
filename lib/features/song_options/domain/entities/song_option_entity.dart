import 'package:equatable/equatable.dart';

/// Entity representing song options data.
class SongOptionEntity extends Equatable {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final String? streamUrl;
  final int? durationSeconds;
  final bool isFavorite;
  final bool isDownloaded;

  const SongOptionEntity({
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.streamUrl,
    this.durationSeconds,
    this.isFavorite = false,
    this.isDownloaded = false,
  });

  SongOptionEntity copyWith({
    String? videoId,
    String? title,
    String? artist,
    String? thumbnail,
    String? streamUrl,
    int? durationSeconds,
    bool? isFavorite,
    bool? isDownloaded,
  }) {
    return SongOptionEntity(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      thumbnail: thumbnail ?? this.thumbnail,
      streamUrl: streamUrl ?? this.streamUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isFavorite: isFavorite ?? this.isFavorite,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  @override
  List<Object?> get props => [
        videoId,
        title,
        artist,
        thumbnail,
        streamUrl,
        durationSeconds,
        isFavorite,
        isDownloaded,
      ];
}
