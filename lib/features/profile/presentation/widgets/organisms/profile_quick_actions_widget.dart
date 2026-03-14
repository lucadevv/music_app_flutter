import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/l10n/app_localizations.dart';

import '../animators/animated_quick_action_widget.dart';
import '../molecules/quick_action_card_widget.dart';

/// Organismo que condensa las acciones rápidas del Perfil.
class ProfileQuickActionsWidget extends StatelessWidget {
  const ProfileQuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        AnimatedQuickActionWidget(
          delay: 0.5,
          child: QuickActionCardWidget(
            icon: Icons.settings_outlined,
            title: l10n.settings,
            subtitle: l10n.appPreferencesAndAccountSettings,
            onTap: () => context.router.push(const SettingsRoute()),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedQuickActionWidget(
          delay: 0.6,
          child: QuickActionCardWidget(
            icon: Icons.download_outlined,
            title: l10n.downloads,
            subtitle: l10n.manageYourDownloadedMusic,
            onTap: () => context.router.push(const DownloadsRoute()),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedQuickActionWidget(
          delay: 0.7,
          child: QuickActionCardWidget(
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
