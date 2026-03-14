// ignore_for_file: deprecated_member_use_from_same_package
import 'package:music_app/features/album/domain/entities/album.dart';

/// Repository contract for album data
abstract class AlbumRepository {
  /// Get album details by ID
  Future<Album> getAlbum(String albumId);

  /// Get album songs
  Future<List<AlbumSong>> getAlbumSongs(String albumId);

  /// Like/unlike album
  Future<void> likeAlbum(String albumId);
  Future<void> unlikeAlbum(String albumId);

  /// Check if album is liked
  Future<bool> isLiked(String albumId);
}
