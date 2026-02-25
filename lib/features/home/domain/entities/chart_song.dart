/// Entidad para canciones en charts (top_songs, trending)
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Representar una canción en los charts
class ChartSong {
  final String videoId;
  final String title;
  final String artist;
  final String streamUrl; // URL de streaming (viene del endpoint con include_stream_urls=true)
  final String thumbnail; // Thumbnail de mejor calidad (viene junto con stream_url)

  const ChartSong({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.streamUrl,
    required this.thumbnail,
  });
}
