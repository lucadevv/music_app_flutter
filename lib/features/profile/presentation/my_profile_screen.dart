import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/profile/profile_cubit.dart';
import 'package:music_app/features/profile/profile_service.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class MyProfileScreen extends StatefulWidget implements AutoRouteWrapper {
  const MyProfileScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => getIt<ProfileCubit>()..loadProfile(),
      child: this,
    );
  }

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // Estadísticas del usuario
  int _favoriteSongsCount = 0;
  int _favoritePlaylistsCount = 0;
  int _favoriteGenresCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadLibraryStats();
  }

  Future<void> _loadLibraryStats() async {
    try {
      final apiServices = getIt<ApiServices>();
      final response = await apiServices.get('/library/summary');

      int songsCount = 0;
      int playlistsCount = 0;
      int genresCount = 0;

      if (response is Response) {
        final data = response.data;
        songsCount = data['favoriteSongs'] ?? 0;
        playlistsCount = data['favoritePlaylists'] ?? 0;
        genresCount = data['favoriteGenres'] ?? 0;
      } else if (response is Map) {
        songsCount = response['favoriteSongs'] ?? 0;
        playlistsCount = response['favoritePlaylists'] ?? 0;
        genresCount = response['favoriteGenres'] ?? 0;
      }

      if (mounted) {
        setState(() {
          _favoriteSongsCount = songsCount;
          _favoritePlaylistsCount = playlistsCount;
          _favoriteGenresCount = genresCount;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _handleLogout(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        title: Text(
          l10n.logoutConfirmation,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.logoutConfirmationMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.logout,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authManager = await getIt.getAsync<AuthManager>();
      await authManager.logout();
    }
  }

  Future<void> _refreshAll() async {
    context.read<ProfileCubit>().loadProfile();
    await _loadLibraryStats();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.myProfile,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.router.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => _handleLogout(context, l10n),
            child: Text(
              l10n.exit,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColorsDark.primary,
              ),
            );
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorLoadingProfile,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColorsDark.primary,
            onRefresh: _refreshAll,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Profile picture
                  _buildAvatar(state),
                  const SizedBox(height: 24),

                  // Name
                  Text(
                    state.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email
                  _ProfileField(
                    label: l10n.email,
                    value: state.email,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Provider
                  _ProfileField(
                    label: l10n.provider,
                    value: state.provider.toUpperCase(),
                    icon: Icons.login,
                  ),
                  const SizedBox(height: 16),

                  // Member since
                  if (state.createdAt != null)
                    _ProfileField(
                      label: l10n.memberSince,
                      value: _formatDate(state.createdAt!, l10n),
                      icon: Icons.calendar_today_outlined,
                    ),
                  const SizedBox(height: 32),

                  // Statistics
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _isLoadingStats
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColorsDark.primary,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatCard(
                                icon: Icons.favorite,
                                number: _favoriteSongsCount.toString(),
                                label: l10n.songs,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              _StatCard(
                                icon: Icons.playlist_play,
                                number: _favoritePlaylistsCount.toString(),
                                label: l10n.playlists,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              _StatCard(
                                icon: Icons.library_music,
                                number: _favoriteGenresCount.toString(),
                                label: l10n.genres,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 32),

                  // Quick actions
                  _QuickActionCard(
                    icon: Icons.settings_outlined,
                    title: l10n.settings,
                    subtitle: l10n.appPreferencesAndAccountSettings,
                    onTap: () => context.router.push(const SettingsRoute()),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionCard(
                    icon: Icons.download_outlined,
                    title: l10n.downloads,
                    subtitle: l10n.manageYourDownloadedMusic,
                    onTap: () => context.router.push(const DownloadsRoute()),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionCard(
                    icon: Icons.language_outlined,
                    title: l10n.language,
                    subtitle: l10n.changeAppLanguage,
                    onTap: () => context.router.push(const LanguageRoute()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(ProfileState state) {
    if (state.avatarUrl != null && state.avatarUrl!.isNotEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColorsDark.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: state.avatarUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildInitialsAvatar(state),
            errorWidget: (_, __, ___) => _buildInitialsAvatar(state),
          ),
        ),
      );
    }
    return _buildInitialsAvatar(state);
  }

  Widget _buildInitialsAvatar(ProfileState state) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsDark.primary,
            AppColorsDark.primary.withValues(alpha: 0.7),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColorsDark.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          state.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final months = [
      l10n.monthsJan, l10n.monthsFeb, l10n.monthsMar, l10n.monthsApr,
      l10n.monthsMay, l10n.monthsJun, l10n.monthsJul, l10n.monthsAug,
      l10n.monthsSep, l10n.monthsOct, l10n.monthsNov, l10n.monthsDec
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColorsDark.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;

  const _StatCard({
    required this.icon,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColorsDark.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColorsDark.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColorsDark.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
