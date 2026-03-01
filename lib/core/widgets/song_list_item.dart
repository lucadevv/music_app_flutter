import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Widget unificado para mostrar items de canciones en listas.
/// Diseño consistente basado en liked songs (SIN índice)
class SongListItem extends StatelessWidget {
  /// Título de la canción
  final String title;
  
  /// Nombre del artista
  final String artist;
  
  /// URL de la miniatura (opcional)
  final String? thumbnail;
  
  /// Widget que se muestra a la derecha (opcional)
  final Widget? trailing;
  
  /// Callback cuando se toca el item
  final VoidCallback? onTap;

  const SongListItem({
    super.key,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 48,
          height: 48,
          color: AppColorsDark.primaryContainer,
          child: thumbnail != null
              ? CachedNetworkImage(
                  imageUrl: thumbnail!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Icon(
                    Icons.music_note,
                    color: AppColorsDark.primary,
                  ),
                )
              : Icon(Icons.music_note, color: AppColorsDark.primary),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// Versión simplificada con botón de favorito integrado
class SongListItemWithFavorite extends StatelessWidget {
  final String title;
  final String artist;
  final String? thumbnail;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const SongListItemWithFavorite({
    super.key,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SongListItem(
      title: title,
      artist: artist,
      thumbnail: thumbnail,
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: AppColorsDark.primary,
          size: 20,
        ),
        onPressed: onFavoriteToggle,
      ),
      onTap: onTap,
    );
  }
}

/// Versión con botón de eliminar
class SongListItemWithRemove extends StatelessWidget {
  final String title;
  final String artist;
  final String? thumbnail;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const SongListItemWithRemove({
    super.key,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SongListItem(
      title: title,
      artist: artist,
      thumbnail: thumbnail,
      trailing: IconButton(
        icon: Icon(
          Icons.remove_circle_outline,
          color: Colors.white.withValues(alpha: 0.6),
          size: 20,
        ),
        onPressed: onRemove,
      ),
      onTap: onTap,
    );
  }
}

/// Versión con widget trailing personalizado
class SongListItemWithTrailing extends StatelessWidget {
  final String title;
  final String artist;
  final String? thumbnail;
  final Widget trailing;
  final VoidCallback? onTap;

  const SongListItemWithTrailing({
    super.key,
    required this.title,
    required this.artist,
    this.thumbnail,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SongListItem(
      title: title,
      artist: artist,
      thumbnail: thumbnail,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
