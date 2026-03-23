import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';

enum LoopModeType { off, one, all }

enum ProcessingStateType { idle, loading, buffering, ready, completed }

class PlayerStateInfo extends Equatable {
  final bool isPlaying;
  final ProcessingStateType processingState;

  const PlayerStateInfo({
    required this.isPlaying,
    required this.processingState,
  });

  @override
  List<Object?> get props => [isPlaying, processingState];
}

class AudioSourceConfig extends Equatable {
  final String id;
  final String url;
  final String? title;
  final String? artist;
  final Duration? duration;
  final MediaItem? mediaItem;

  const AudioSourceConfig({
    required this.id,
    required this.url,
    this.title,
    this.artist,
    this.duration,
    this.mediaItem,
  });

  @override
  List<Object?> get props => [id, url, title, artist, duration, mediaItem];
}
