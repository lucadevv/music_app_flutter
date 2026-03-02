import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';

import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

/// Interfaz de repositorio para operaciones con canciones.
///
/// Esta es la interfaz de dominio que debe ser implementada
/// por la capa de datos.
///
/// Principios:
/// - SOLID: Interface Segregation - interfaz específica para canciones
/// - Clean Architecture: Esta interfaz vive en dominio, no tiene dependencias externas
abstract class SongRepository {
  /// Busca canciones por query
  Future<Either<AppException, List<Song>>> searchSongs(String query);

  /// Obtiene las canciones más populares
  Future<Either<AppException, List<Song>>> getTrendingSongs({int limit = 20});

  /// Obtiene las canciones de un álbum
  Future<Either<AppException, List<Song>>> getAlbumSongs(String albumId);

  /// Obtiene las canciones de un artista
  Future<Either<AppException, List<Song>>> getArtistSongs(String artistId);

  /// Obtiene las canciones descargadas
  Future<Either<AppException, List<Song>>> getDownloadedSongs();

  /// Obtiene el historial de canciones reproducidas
  Future<Either<AppException, List<Song>>> getRecentlyPlayed({int limit = 50});

  /// Obtiene las canciones favoritas del usuario
  Future<Either<AppException, List<Song>>> getFavoriteSongs();

  /// Añade una canción a favoritos
  Future<Either<AppException, void>> addToFavorites(Song song);

  /// Elimina una canción de favoritos
  Future<Either<AppException, void>> removeFromFavorites(String videoId);

  /// Verifica si una canción está en favoritos
  Future<Either<AppException, bool>> isFavorite(String videoId);

  /// Obtiene una canción por su ID
  Future<Either<AppException, Song>> getSongById(String videoId);

  /// Obtiene songs relacionados/Recomendadas
  Future<Either<AppException, List<Song>>> getRelatedSongs(
    String videoId, {
    int limit = 20,
  });
}

/// Entidad Song importada desde el dominio
// ignore: unused_import (se usa en la documentación)
