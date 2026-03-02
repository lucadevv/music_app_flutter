import 'song.dart';

/// Entidad del dominio para la respuesta de búsqueda
class SearchResponse {
  final List<Song> results;
  final String query;

  const SearchResponse({required this.results, required this.query});
}
