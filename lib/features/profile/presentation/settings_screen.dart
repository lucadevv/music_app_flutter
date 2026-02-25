import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Settings section
          _SettingsSection(
            title: 'Settings',
            items: [
              _SettingsItem(
                icon: Icons.language,
                title: 'Music Language(s)',
                trailing: const Text('English, Tamil', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.router.push(const LanguageRoute());
                },
              ),
              _SettingsItem(
                icon: Icons.high_quality,
                title: 'Streaming Quality',
                trailing: const Text('HD', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.router.push(const StreamingQualityRoute());
                },
              ),
              _SettingsItem(
                icon: Icons.download,
                title: 'Download Quality',
                trailing: const Text('HD', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.router.push(const DownloadsRoute());
                },
              ),
              _SwitchSettingsItem(
                icon: Icons.play_arrow,
                title: 'Auto-Play',
                value: true,
                onChanged: (value) {},
              ),
              _SwitchSettingsItem(
                icon: Icons.lyrics,
                title: 'Show Lyrics on Player',
                value: true,
                onChanged: (value) {},
              ),
              _SettingsItem(
                icon: Icons.graphic_eq,
                title: 'Equalizer',
                subtitle: 'Adjust audio settings',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.devices,
                title: 'Connect to a Device',
                subtitle: 'Listen to and control music on your devices',
                onTap: () {},
              ),
            ],
          ),

          // Others section
          _SettingsSection(
            title: 'Others',
            items: [
              _SettingsItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.logout,
                title: 'Logout',
                textColor: Colors.red,
                onTap: () {
                  context.router.push(const LogoutRoute());
                },
              ),
            ],
          ),
        ],
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
