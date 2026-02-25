import '../../domain/entities/search_response.dart';
import 'song_model.dart';

/// Modelo de datos para la respuesta de búsqueda
class SearchResponseModel extends SearchResponse {
  const SearchResponseModel({required super.results, required super.query});

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    return SearchResponseModel(
      results: (json['results'] as List<dynamic>)
          .map((result) => SongModel.fromJson(result as Map<String, dynamic>))
          .toList(),
      query: json['query'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((song) => (song as SongModel).toJson()).toList(),
      'query': query,
    };
  }
}
