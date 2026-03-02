import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/bloc/locale_cubit.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ProfileCubit>()
            ..loadProfile()
            ..loadSettings(),
        ),
        BlocProvider(create: (_) => getIt<LocaleCubit>()),
      ],
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  // Formatting methods (simple helpers that don't need to be in Cubit)
  String _getLanguageName(String code, AppLocalizations l10n) {
    final names = {
      'en': l10n.english,
      'es': 'Español',
      'pt': 'Português',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'ja': '日本語',
      'ko': '한국어',
      'zh': '中文',
    };
    return names[code] ?? code;
  }

  String _getQualityName(String quality) {
    final names = {
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'hd': 'HD',
      'uhd': 'UHD',
    };
    return names[quality] ?? quality;
  }

  String _getEqualizerName(String preset) {
    final names = {
      'flat': 'Flat',
      'rock': 'Rock',
      'pop': 'Pop',
      'bass_boost': 'Bass Boost',
      'treble_boost': 'Treble Boost',
      'vocal': 'Vocal',
      'classical': 'Classical',
      'jazz': 'Jazz',
      'electronic': 'Electronic',
      'custom': 'Custom',
    };
    return names[preset] ?? preset;
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
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  if (!profileState.isLoading && profileState.error == null)
                    _ProfileHeader(profileState: profileState, l10n: l10n),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: l10n.settings,
                    items: [
                      _SettingsItem(
                        icon: Icons.language,
                        title: l10n.musicLanguages,
                        trailing: Text(
                          _getLanguageName(
                            localeState.locale.languageCode,
                            l10n,
                          ),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () => context.router.push(const LanguageRoute()),
                      ),
                      _SettingsItem(
                        icon: Icons.high_quality,
                        title: l10n.streamingQuality,
                        trailing: Text(
                          _getQualityName(
                            profileState.settings?.streamingQuality ?? 'high',
                          ),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () => _showQualityPicker(
                          context,
                          'streaming',
                          profileState.settings?.streamingQuality ?? 'high',
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.download,
                        title: l10n.downloadQuality,
                        trailing: Text(
                          _getQualityName(
                            profileState.settings?.downloadQuality ?? 'high',
                          ),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () => _showQualityPicker(
                          context,
                          'download',
                          profileState.settings?.downloadQuality ?? 'high',
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.equalizer,
                        title: l10n.equalizer,
                        trailing: Text(
                          _getEqualizerName(
                            profileState.settings?.equalizerPreset ?? 'flat',
                          ),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () =>
                            context.router.push(const EqualizerRoute()),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showQualityPicker(
    BuildContext context,
    String type,
    String currentQuality,
  ) {
    final qualities = ['low', 'medium', 'high', 'hd', 'uhd'];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: qualities.length,
        itemBuilder: (context, index) {
          final quality = qualities[index];
          final isSelected = quality == currentQuality;

          return RadioListTile<String>(
            value: quality,
            groupValue: currentQuality,
            onChanged: (value) {
              if (value != null) {
                if (type == 'streaming') {
                  context.read<ProfileCubit>().updateStreamingQuality(value);
                } else {
                  context.read<ProfileCubit>().updateDownloadQuality(value);
                }
                Navigator.pop(ctx);
              }
            },
            title: Text(
              _getQualityName(quality),
              style: const TextStyle(color: Colors.white),
            ),
            activeColor: AppColorsDark.primary,
            selected: isSelected,
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
            _buildAvatar(),
            const SizedBox(width: 16),
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profileState.email,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
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

  Widget _buildAvatar() {
    if (profileState.avatarUrl != null && profileState.avatarUrl!.isNotEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(shape: BoxShape.circle),
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

  const _SettingsSection({required this.title, required this.items});

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
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing:
          trailing ??
          Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6)),
      onTap: onTap,
    );
  }
}
