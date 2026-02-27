import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/profile/profile_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget implements AutoRouteWrapper {
  const SettingsScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => getIt<ProfileCubit>()..loadProfile(),
      child: this,
    );
  }

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.settings,
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
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Profile header
              if (!profileState.isLoading && profileState.error == null)
                _ProfileHeader(profileState: profileState, l10n: l10n),

              const SizedBox(height: 16),

              // Settings section
              _SettingsSection(
                title: l10n.settings,
                items: [
                  _SettingsItem(
                    icon: Icons.language,
                    title: l10n.musicLanguages,
                    trailing: Text(l10n.english, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      context.router.push(const LanguageRoute());
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.high_quality,
                    title: l10n.streamingQuality,
                    trailing: Text(l10n.hd, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      context.router.push(const StreamingQualityRoute());
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.download,
                    title: l10n.downloadQuality,
                    trailing: Text(l10n.hd, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      context.router.push(const DownloadsRoute());
                    },
                  ),
                  _SwitchSettingsItem(
                    icon: Icons.play_arrow,
                    title: l10n.autoPlay,
                    value: true,
                    onChanged: (value) {},
                  ),
                  _SwitchSettingsItem(
                    icon: Icons.lyrics,
                    title: l10n.showLyricsOnPlayer,
                    value: true,
                    onChanged: (value) {},
                  ),
                  _SettingsItem(
                    icon: Icons.graphic_eq,
                    title: l10n.equalizer,
                    subtitle: l10n.adjustAudioSettings,
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.devices,
                    title: l10n.connectToDevice,
                    subtitle: l10n.listenAndControlOnDevices,
                    onTap: () {},
                  ),
                ],
              ),

              // Others section
              _SettingsSection(
                title: l10n.others,
                items: [
                  _SettingsItem(
                    icon: Icons.help_outline,
                    title: l10n.helpAndSupport,
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.logout,
                    title: l10n.logout,
                    textColor: Colors.red,
                    onTap: () {
                      context.router.push(const LogoutRoute());
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileState profileState;
  final AppLocalizations l10n;

  const _ProfileHeader({required this.profileState, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.router.push(const MyProfileRoute()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profileState.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profileState.email,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColorsDark.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          profileState.provider.toUpperCase(),
                          style: TextStyle(
                            color: AppColorsDark.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (profileState.isEmailVerified) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 14,
                        ),
                      ],
                    ],
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

  Widget _buildAvatar() {
    if (profileState.avatarUrl != null && profileState.avatarUrl!.isNotEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColorsDark.primaryContainer,
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: profileState.avatarUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildInitials(),
            errorWidget: (_, __, ___) => _buildInitials(),
          ),
        ),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    return Container(
      width: 56,
      height: 56,
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
      ),
      child: Center(
        child: Text(
          profileState.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(
        icon,
        color: textColor ?? Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            )
          : null,
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: Colors.white.withValues(alpha: 0.6),
          ),
      onTap: onTap,
    );
  }
}

class _SwitchSettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSettingsItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColorsDark.primary,
      ),
    );
  }
}
