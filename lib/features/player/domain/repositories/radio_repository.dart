/// Repository interface para obtener playlists de radio
abstract class RadioRepository {
  /// Obtiene canciones similares/radio para un videoId
  Future<List<Map<String, dynamic>>> getRadioPlaylist(String videoId, {int limit = 10});
}
