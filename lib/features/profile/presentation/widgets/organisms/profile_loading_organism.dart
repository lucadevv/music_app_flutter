import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';

/// Organismo que muestra el estado de carga del perfil.
class ProfileLoadingOrganism extends StatelessWidget {
  const ProfileLoadingOrganism({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: const [
        // Fake Profile Header
        Padding(
          padding: EdgeInsets.all(24.0),
          child: Row(
            children: [
              ShimmerContainer(width: 60, height: 60, borderRadius: 30),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextShimmer(width: 150, height: 24),
                    SizedBox(height: 8),
                    TextShimmer(width: 200, height: 14),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColorsDark.onSurface54),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(color: AppColorsDark.onSurface12),
        ),
        SizedBox(height: 16),
        // Fake Option
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              ShimmerContainer(width: 24, height: 24, borderRadius: 12),
              SizedBox(width: 16),
              TextShimmer(width: 120, height: 16),
            ],
          ),
        ),
        // Fake Option 2
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              ShimmerContainer(width: 24, height: 24, borderRadius: 12),
              SizedBox(width: 16),
              TextShimmer(width: 160, height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
