// ignore_for_file: use_build_context_synchronously
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';

import 'widgets/molecules/profile_avatar_widget.dart';
import 'widgets/organisms/profile_info_section_widget.dart';
import 'widgets/organisms/profile_quick_actions_widget.dart';
import 'widgets/organisms/profile_stats_row_widget.dart';

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
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
      child: ProfileAvatarWidget(
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
    return ProfileInfoSectionWidget(state: state);
  }

  Widget _buildStatsSection(
    BuildContext context,
    AppLocalizations l10n,
    ProfileState state,
  ) {
    return ProfileStatsRowWidget(state: state, entryDelay: 0.4);
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return const ProfileQuickActionsWidget();
  }
}
