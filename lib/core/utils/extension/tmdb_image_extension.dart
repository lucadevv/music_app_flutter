extension TMDBImageExtension on String? {
  static const String _baseUrl = 'https://image.tmdb.org/t/p/';

  String? tmdbUrl(String size) {
    if (this == null || this!.isEmpty) return null;

    final cleanPath = this!.startsWith('/') ? this!.substring(1) : this!;
    return '$_baseUrl$size/$cleanPath';
  }

  String? get tmdbW92 => tmdbUrl('w92');
  String? get tmdbW154 => tmdbUrl('w154');
  String? get tmdbW185 => tmdbUrl('w185');
  String? get tmdbW342 => tmdbUrl('w342');
  String? get tmdbW500 => tmdbUrl('w500');
  String? get tmdbW780 => tmdbUrl('w780');
  String? get tmdbOriginal => tmdbUrl('original');

  String? get tmdbBackdropW300 => tmdbUrl('w300');
  String? get tmdbBackdropW780 => tmdbUrl('w780');
  String? get tmdbBackdropW1280 => tmdbUrl('w1280');

  String? get tmdbProfileW45 => tmdbUrl('w45');
  String? get tmdbProfileW185 => tmdbUrl('w185');
  String? get tmdbProfileH632 => tmdbUrl('h632');

  String? get asPosterThumbnail => tmdbW185;
  String? get asPosterMedium => tmdbW342;
  String? get asPosterLarge => tmdbW500;
  String? get asBackdropMedium => tmdbBackdropW780;
  String? get asBackdropLarge => tmdbBackdropW1280;
  String? get asProfileThumbnail => tmdbProfileW45;
  String? get asProfileMedium => tmdbProfileW185;
}
