import '../../domain/entities/artist.dart';

/// Modelo de datos para el artista en los resultados de búsqueda
class SearchArtistModel extends SearchArtist {
  const SearchArtistModel({required super.name, required super.id});

  factory SearchArtistModel.fromJson(Map<String, dynamic> json) {
    return SearchArtistModel(
      name: json['name'] as String? ?? '',
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'id': id};
  }
}
