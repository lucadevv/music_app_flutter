import '../../domain/entities/search_response.dart';
import 'song_model.dart';

/// Modelo de datos para la respuesta de búsqueda
class SearchResponseModel extends SearchResponse {
  const SearchResponseModel({required super.results, required super.query});

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final resultsList = json['results'] as List<dynamic>? ?? [];
    
    final parsedResults = resultsList
        .whereType<Map<String, dynamic>>()
        .map((result) {
          try { return SongModel.fromJson(result); } catch (_) { return null; }
        })
        .whereType<SongModel>()
        .toList();

    return SearchResponseModel(
      results: parsedResults,
      query: json['query'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((song) => (song as SongModel).toJson()).toList(),
      'query': query,
    };
  }
}
