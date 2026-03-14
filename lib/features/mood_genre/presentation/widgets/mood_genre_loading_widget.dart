import 'package:flutter/material.dart';

import 'package:music_app/core/widgets/shimmer_widgets.dart';

/// Widget para mostrar el estado de carga con shimmer
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar el estado de carga geométricamente afín
class MoodGenreLoadingWidget extends StatelessWidget {
  const MoodGenreLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // AppBar con shimmer (botón volver + título)
          const SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: SizedBox(
               width: 48, 
               height: 48,
               child: Center(
                 child: ShimmerContainer(width: 24, height: 24, borderRadius: 12),
               ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Align(
                alignment: Alignment.bottomLeft,
                child: TextShimmer(width: 150, height: 20),
              ),
              centerTitle: false,
            ),
          ),

          // Espaciador falso: "Playlists de la comunidad"
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: TextShimmer(width: 200, height: 20),
            ),
          ),

          // Grid de playlists shimmer
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Usar Expanded para que el Thumbnail ocupe todo el espacio sobrante posible
                      Expanded(
                        child: ShimmerContainer(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Título
                      TextShimmer(width: double.infinity, height: 14),
                      SizedBox(height: 4),
                      TextShimmer(width: 80, height: 14),
                    ],
                  );
                },
                childCount: 16,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
