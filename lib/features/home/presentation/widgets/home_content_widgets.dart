import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/home/domain/entities/home_content_item.dart';

/// Widget para mostrar una canción en formato card horizontal
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar una card de canción
class SongCardWidget extends StatelessWidget {
  final HomeContentItem item;
  final VoidCallback onTap;

  const SongCardWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = item.thumbnails.isNotEmpty ? item.thumbnails.last : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColorsDark.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: thumbnail != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: thumbnail.url,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColorsDark.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.music_note,
                            size: 60,
                            color: AppColorsDark.primary,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.music_note,
                          size: 60,
                          color: AppColorsDark.primary,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.artists.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.artists.map((a) => a.name).join(', '),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar una playlist en formato card horizontal
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar una card de playlist
class PlaylistCardWidget extends StatelessWidget {
  final HomeContentItem item;
  final VoidCallback? onTap;

  const PlaylistCardWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = item.thumbnails.isNotEmpty ? item.thumbnails.last : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColorsDark.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: thumbnail != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: thumbnail.url,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColorsDark.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.playlist_play,
                            size: 60,
                            color: AppColorsDark.primary,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.playlist_play,
                          size: 60,
                          color: AppColorsDark.primary,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar una canción en formato lista vertical
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar un item de lista de canción
class SongListItemWidget extends StatelessWidget {
  final HomeContentItem item;
  final VoidCallback onTap;

  const SongListItemWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = item.thumbnails.isNotEmpty ? item.thumbnails.first : null;

    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: thumbnail != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: thumbnail.url,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 56,
                    height: 56,
                    color: AppColorsDark.primaryContainer,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColorsDark.primary,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColorsDark.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.music_note,
                      color: AppColorsDark.primary,
                    ),
                  ),
                ),
              )
            : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColorsDark.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.music_note,
                  color: AppColorsDark.primary,
                ),
              ),
        title: Text(
          item.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          item.artists.isNotEmpty
              ? item.artists.map((a) => a.name).join(', ')
              : item.views,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}

/// Widget para mostrar una playlist en formato lista vertical
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar un item de lista de playlist
class PlaylistListItemWidget extends StatelessWidget {
  final HomeContentItem item;
  final VoidCallback? onTap;

  const PlaylistListItemWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = item.thumbnails.isNotEmpty ? item.thumbnails.first : null;

    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: thumbnail != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: thumbnail.url,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 56,
                    height: 56,
                    color: AppColorsDark.primaryContainer,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColorsDark.primary,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColorsDark.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.playlist_play,
                      color: AppColorsDark.primary,
                    ),
                  ),
                ),
              )
            : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColorsDark.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.playlist_play,
                  color: AppColorsDark.primary,
                ),
              ),
        title: Text(
          item.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          item.description ?? '',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}
