import 'package:equatable/equatable.dart';

/// Entidad del dominio para una canción en los resultados de búsqueda
///
/// @deprecated Usar [Song] desde `core/domain/entities/song.dart`
/// Esta entidad será eliminada en futuras versiones.
/// Usar [SongMapper] para convertir a la entidad centralizada.
@Deprecated('Usar Song desde core/domain/entities/song.dart')
class Song {
  final String title;
  final SearchAlbum album;
  final List<SearchArtist> artists;
  final String videoId;
  final String duration;
  final int durationSeconds;
  final String views;
  final bool isExplicit;
  final bool inLibrary;
  final List<Thumbnail> thumbnails;
  final String?
  streamUrl; // URL de streaming (viene del endpoint con include_stream_urls=true)
  final Thumbnail?
  thumbnail; // Thumbnail de mejor calidad (viene junto con stream_url)

  const Song({
    required this.title,
    required this.album,
    required this.artists,
    required this.videoId,
    required this.duration,
    required this.durationSeconds,
    required this.views,
    required this.isExplicit,
    required this.inLibrary,
    required this.thumbnails,
    this.streamUrl,
    this.thumbnail,
  });
}

/// Entidad de álbum en búsqueda
class SearchAlbum {
  final String id;
  final String name;
  final List<SearchArtist> artists;

  const SearchAlbum({
    required this.id,
    required this.name,
    required this.artists,
  });
}

/// Entidad de artista
class SearchArtist {
  final String id;
  final String name;

  const SearchArtist({required this.id, required this.name});
}

/// Miniaturas en diferentes tamaños
class Thumbnail extends Equatable {
  final String url;
  final int? width;
  final int? height;

  const Thumbnail({required this.url, this.width, this.height});

  @override
  List<Object?> get props => [url, width, height];
}
