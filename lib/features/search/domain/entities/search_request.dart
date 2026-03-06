/// Entidad del dominio para la solicitud de búsqueda
class SearchRequest {
  final String query;
  final String filter; // 'songs', 'artists', 'albums', etc.
  final int startIndex; // Para paginación

  const SearchRequest({
    required this.query,
    this.filter = 'songs',
    this.startIndex = 0,
  });
}
