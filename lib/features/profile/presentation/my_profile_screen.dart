import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/format_utils.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Cargar profile y estadísticas
    context.read<ProfileCubit>().loadProfile();
    context.read<ProfileCubit>().loadLibraryStats();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
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
            child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ProfileCubit>().logout();
    }
  }

  Future<void> _refreshAll() async {
    await context.read<ProfileCubit>().loadProfile();
    await context.read<ProfileCubit>().loadLibraryStats();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: _buildAppBar(context, l10n),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColorsDark.primary),
            );
          }

          if (state.error != null) {
            return _buildErrorState(context, l10n, state);
          }

          return _buildContent(context, l10n, state);
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
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
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    ProfileState state,
  ) {
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

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    ProfileState state,
  ) {
    return RefreshIndicator(
      color: AppColorsDark.primary,
      onRefresh: _refreshAll,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(position: _slideAnimation, child: child),
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildAvatarSection(state),
              const SizedBox(height: 24),
              _buildNameSection(state),
              const SizedBox(height: 32),
              _buildInfoSection(context, l10n, state),
              const SizedBox(height: 32),
              _buildStatsSection(context, l10n, state),
              const SizedBox(height: 32),
              _buildQuickActions(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(ProfileState state) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: _ProfileAvatar(
        avatarUrl: state.avatarUrl,
        initials: state.initials,
      ),
    );
  }

  Widget _buildNameSection(ProfileState state) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        state.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    AppLocalizations l10n,
    ProfileState state,
  ) {
    final months = [
      l10n.monthsJan,
      l10n.monthsFeb,
      l10n.monthsMar,
      l10n.monthsApr,
      l10n.monthsMay,
      l10n.monthsJun,
      l10n.monthsJul,
      l10n.monthsAug,
      l10n.monthsSep,
      l10n.monthsOct,
      l10n.monthsNov,
      l10n.monthsDec,
    ];

    return Column(
      children: [
        _AnimatedProfileField(
          delay: 0.1,
          child: _ProfileField(
            label: l10n.email,
            value: state.email,
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedProfileField(
          delay: 0.2,
          child: _ProfileField(
            label: l10n.provider,
            value: state.provider.toUpperCase(),
            icon: Icons.login,
          ),
        ),
        const SizedBox(height: 16),
        if (state.createdAt != null)
          _AnimatedProfileField(
            delay: 0.3,
            child: _ProfileField(
              label: l10n.memberSince,
              value: FormatUtils.date(state.createdAt!, months),
              icon: Icons.calendar_today_outlined,
            ),
          ),
      ],
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    AppLocalizations l10n,
    ProfileState state,
  ) {
    return _AnimatedStatCard(
      delay: 0.4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: state.isLoadingStats
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
                    number: state.favoriteSongsCount.toString(),
                    label: l10n.songs,
                    onTap: () => context.router.push(const LikedSongsRoute()),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  _StatCard(
                    icon: Icons.playlist_play,
                    number: state.favoritePlaylistsCount.toString(),
                    label: l10n.playlists,
                    onTap: () {
                      // TODO: Implement navigation to playlists tab
                    },
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  _StatCard(
                    icon: Icons.library_music,
                    number: state.favoriteGenresCount.toString(),
                    label: l10n.genres,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        _AnimatedQuickAction(
          delay: 0.5,
          child: _QuickActionCard(
            icon: Icons.settings_outlined,
            title: l10n.settings,
            subtitle: l10n.appPreferencesAndAccountSettings,
            onTap: () => context.router.push(const SettingsRoute()),
          ),
        ),
        const SizedBox(height: 12),
        _AnimatedQuickAction(
          delay: 0.6,
          child: _QuickActionCard(
            icon: Icons.download_outlined,
            title: l10n.downloads,
            subtitle: l10n.manageYourDownloadedMusic,
            onTap: () => context.router.push(const DownloadsRoute()),
          ),
        ),
        const SizedBox(height: 12),
        _AnimatedQuickAction(
          delay: 0.7,
          child: _QuickActionCard(
            icon: Icons.language_outlined,
            title: l10n.language,
            subtitle: l10n.changeAppLanguage,
            onTap: () => context.router.push(const LanguageRoute()),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// WIDGETS PEQUEÑOS - Following Clean Architecture y Single Responsibility
// ============================================================================

class _ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;

  const _ProfileAvatar({required this.avatarUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return _buildNetworkImage();
    }
    return _buildInitialsAvatar();
  }

  Widget _buildNetworkImage() {
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
          imageUrl: avatarUrl!,
          fit: BoxFit.cover,
          placeholder: (_, _) => _buildInitialsAvatar(),
          errorWidget: (_, _, _) => _buildInitialsAvatar(),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
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
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
          Icon(icon, color: AppColorsDark.primary, size: 24),
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
                  style: const TextStyle(color: Colors.white, fontSize: 16),
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
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.number,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppColorsDark.primary, size: 24),
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
      ),
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
              child: Icon(icon, color: AppColorsDark.primary, size: 24),
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

/// Animated wrapper for profile fields
class _AnimatedProfileField extends StatefulWidget {
  final double delay;
  final Widget child;

  const _AnimatedProfileField({required this.delay, required this.child});

  @override
  State<_AnimatedProfileField> createState() => _AnimatedProfileFieldState();
}

class _AnimatedProfileFieldState extends State<_AnimatedProfileField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Animated wrapper for stat card
class _AnimatedStatCard extends StatefulWidget {
  final double delay;
  final Widget child;

  const _AnimatedStatCard({required this.delay, required this.child});

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}

/// Animated wrapper for quick actions
class _AnimatedQuickAction extends StatefulWidget {
  final double delay;
  final Widget child;

  const _AnimatedQuickAction({required this.delay, required this.child});

  @override
  State<_AnimatedQuickAction> createState() => _AnimatedQuickActionState();
}

class _AnimatedQuickActionState extends State<_AnimatedQuickAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
