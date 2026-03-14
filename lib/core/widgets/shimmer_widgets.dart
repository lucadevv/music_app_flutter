import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widgets de shimmer genéricos para toda la app
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar placeholders de carga con shimmer

/// Colores base para shimmer en tema oscuro
class ShimmerColors {
  static Color get baseColor => Colors.white.withValues(alpha: 0.1);
  static Color get highlightColor => Colors.white.withValues(alpha: 0.2);
}

/// Shimmer base wrapper
class BaseShimmer extends StatelessWidget {
  final Widget child;

  const BaseShimmer({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ShimmerColors.baseColor,
      highlightColor: ShimmerColors.highlightColor,
      child: child,
    );
  }
}

/// Contenedor base para shimmer
class ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer para avatar circular
class AvatarShimmer extends StatelessWidget {
  final double size;

  const AvatarShimmer({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Shimmer para thumbnail rectangular (álbum, playlist, etc.)
class ThumbnailShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ThumbnailShimmer({
    required this.width, required this.height, super.key,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

/// Shimmer para texto (título, subtítulo, etc.)
class TextShimmer extends StatelessWidget {
  final double width;
  final double height;

  const TextShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: width,
      height: height,
    );
  }
}

/// Shimmer para botón de acción
class ButtonShimmer extends StatelessWidget {
  final double width;
  final double height;

  const ButtonShimmer({
    super.key,
    this.width = 120,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: width,
      height: height,
      borderRadius: 24,
    );
  }
}

/// Shimmer para lista de canciones (Equals to SongListItem geometry)
class SongListItemShimmer extends StatelessWidget {
  const SongListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          ThumbnailShimmer(width: 48, height: 48, borderRadius: 4),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextShimmer(height: 15),
                SizedBox(height: 6),
                TextShimmer(width: 100, height: 13),
              ],
            ),
          ),
          SizedBox(width: 24), // trailing placeholder
        ],
      ),
    );
  }
}

/// Shimmer para card horizontal de canción
class SongCardShimmer extends StatelessWidget {
  final double width;
  final double height;

  const SongCardShimmer({
    super.key,
    this.width = 160,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThumbnailShimmer(
            width: width,
            height: height - 50,
            borderRadius: 12,
          ),
          const SizedBox(height: 8),
          const TextShimmer(height: 14),
          const SizedBox(height: 4),
          const TextShimmer(width: 80, height: 12),
        ],
      ),
    );
  }
}

/// Shimmer para lista de artistas
class ArtistListItemShimmer extends StatelessWidget {
  const ArtistListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          AvatarShimmer(size: 64),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextShimmer(height: 16),
                SizedBox(height: 8),
                TextShimmer(width: 80, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer para header de sección
class SectionHeaderShimmer extends StatelessWidget {
  const SectionHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: TextShimmer(width: 150, height: 20),
    );
  }
}

/// Shimmer para grid de categorías (moods, géneros)
class CategoriesGridShimmer extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const CategoriesGridShimmer({
    super.key,
    this.itemCount = 9,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const ShimmerContainer(borderRadius: 12);
      },
    );
  }
}

/// Shimmer para barra de búsqueda
class SearchBarShimmer extends StatelessWidget {
  const SearchBarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ShimmerContainer(height: 48, borderRadius: 24),
    );
  }
}

/// Shimmer para perfil de usuario
class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          AvatarShimmer(size: 80),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextShimmer(width: 150, height: 20),
                SizedBox(height: 8),
                TextShimmer(width: 120, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer para lista de descargas
class DownloadItemShimmer extends StatelessWidget {
  const DownloadItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          ThumbnailShimmer(width: 48, height: 48, borderRadius: 4),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextShimmer(height: 15),
                SizedBox(height: 6),
                TextShimmer(width: 80, height: 13),
              ],
            ),
          ),
          ShimmerContainer(width: 24, height: 24, borderRadius: 4),
        ],
      ),
    );
  }
}
