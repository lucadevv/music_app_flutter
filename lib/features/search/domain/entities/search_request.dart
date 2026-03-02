/// Entidad del dominio para la solicitud de búsqueda
class SearchRequest {
  final String query;
  final String filter; // 'songs', 'artists', 'albums', etc.

  const SearchRequest({required this.query, this.filter = 'songs'});
}
