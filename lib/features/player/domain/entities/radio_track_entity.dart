import 'package:equatable/equatable.dart';

/// Entidad de dominio para una canción de radio (similar songs)
///
/// Esta es la entidad canónica usada en la capa de presentación
class RadioTrackEntity extends Equatable {
  final String videoId;
  final String title;
  final String? artist;
  final List<String>? artists;
  final String? thumbnail;
  final String? streamUrl;
  final String? length;
  final int durationSeconds;

  const RadioTrackEntity({
    required this.videoId,
    required this.title,
    this.artist,
    this.artists,
    this.thumbnail,
    this.streamUrl,
    this.length,
    this.durationSeconds = 0,
  });

  /// Obtiene el nombre del artista formateado
  String get displayArtist {
    if (artists != null && artists!.isNotEmpty) {
      return artists!.join(', ');
    }
    return artist ?? 'Unknown Artist';
  }

  @override
  List<Object?> get props => [
    videoId,
    title,
    artist,
    artists,
    thumbnail,
    streamUrl,
    length,
    durationSeconds,
  ];
}
