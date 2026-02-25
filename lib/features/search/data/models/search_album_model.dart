import '../../domain/entities/album.dart';

/// Modelo de datos para el álbum en los resultados de búsqueda
class SearchAlbumModel extends SearchAlbum {
  const SearchAlbumModel({
    required super.name,
    required super.id,
  });

  factory SearchAlbumModel.fromJson(Map<String, dynamic> json) {
    return SearchAlbumModel(
      name: json['name'] as String? ?? '',
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}
