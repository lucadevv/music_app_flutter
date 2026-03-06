import 'song.dart';

/// Entidad del dominio para la respuesta de búsqueda
class SearchResponse {
  final List<Song> results;
  final String query;
  
  // Campos adicionales para paginación
  final List<dynamic> albums;
  final List<dynamic> artists;

  const SearchResponse({
    required this.results,
    required this.query,
    this.albums = const [],
    this.artists = const [],
  });
}
