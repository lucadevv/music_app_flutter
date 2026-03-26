import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/custom_search_bar.dart';
import 'package:music_app/features/library/presentation/widgets/atoms/profile_avatar.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Header de la pantalla de biblioteca con búsqueda y acciones.
class LibraryHeader extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCreatePlaylist;

  const LibraryHeader({
    required this.searchController,
    required this.onSearchChanged,
    required this.onCreatePlaylist,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l10n.yourLibrary,
                  style: const TextStyle(
                    color: AppColorsDark.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                Row(
                  children: [
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, profileState) {
                        return GestureDetector(
                          onTap: () =>
                              context.router.push(const MyProfileRoute()),
                          child: ProfileAvatar(
                            avatarUrl: profileState.avatarUrl,
                            initials: profileState.initials.isNotEmpty
                                ? profileState.initials
                                : 'U',
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColorsDark.onSurface.withValues(alpha: 0.8),
                          size: 20,
                        ),
                      ),
                      color: AppColorsDark.surfaceContainerHigh,
                      onSelected: (value) {
                        if (value == 'create_playlist') {
                          onCreatePlaylist();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'create_playlist',
                          child: Row(
                            children: [
                              Icon(
                                Icons.playlist_add,
                                color: AppColorsDark.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.createPlaylist,
                                style: const TextStyle(
                                  color: AppColorsDark.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomSearchBar(
              hintText: l10n.searchFor,
              controller: searchController,
              onChanged: onSearchChanged,
            ),
          ],
        ),
      ),
    );
  }
}
