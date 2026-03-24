// ignore_for_file: deprecated_member_use, unnecessary_underscores
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/bloc/locale_cubit.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/features/profile/presentation/widgets/atoms/settings_item_atom.dart';
import 'package:music_app/features/profile/presentation/widgets/molecules/settings_section_molecule.dart';
import 'package:music_app/features/profile/presentation/widgets/organisms/profile_header_organism.dart';
import 'package:music_app/features/profile/presentation/widgets/organisms/quality_picker_organism.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cargar datos del perfil al entrar a la pantalla
    // Los Cubits LocaleCubit y ProfileCubit son singletons proporcionados en app.dart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileCubit = context.read<ProfileCubit>();
      if (!profileCubit.state.isLoading && profileCubit.state.profile == null) {
        profileCubit.loadProfile();
        profileCubit.loadSettings();
      }
    });
    return const _SettingsView();
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
                    ProfileHeaderOrganism(
                      displayName: profileState.displayName,
                      email: profileState.email,
                      initials: profileState.initials,
                      avatarUrl: profileState.avatarUrl,
                    ),
                  const SizedBox(height: 16),
                  _buildSettingsSection(
                    context,
                    profileState,
                    localeState,
                    l10n,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    ProfileState profileState,
    LocaleState localeState,
    AppLocalizations l10n,
  ) {
    return SettingsSectionMolecule(
      title: l10n.settings,
      items: [
        SettingsItemAtom(
          icon: Icons.language,
          title: l10n.musicLanguages,
          trailing: Text(
            QualityPickerOrganism.getLanguageName(
              localeState.locale.languageCode,
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: () => context.router.push(const LanguageRoute()),
        ),
        SettingsItemAtom(
          icon: Icons.high_quality,
          title: l10n.streamingQuality,
          trailing: Text(
            QualityPickerOrganism.getQualityName(
              profileState.settings?.streamingQuality ?? 'high',
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: () => QualityPickerOrganism.show(
            context,
            'streaming',
            profileState.settings?.streamingQuality ?? 'high',
          ),
        ),
        SettingsItemAtom(
          icon: Icons.download,
          title: l10n.downloadQuality,
          trailing: Text(
            QualityPickerOrganism.getQualityName(
              profileState.settings?.downloadQuality ?? 'high',
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: () => QualityPickerOrganism.show(
            context,
            'download',
            profileState.settings?.downloadQuality ?? 'high',
          ),
        ),
        SettingsItemAtom(
          icon: Icons.equalizer,
          title: l10n.equalizer,
          trailing: Text(
            QualityPickerOrganism.getEqualizerName(
              profileState.settings?.equalizerPreset ?? 'flat',
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: () => context.router.push(const EqualizerRoute()),
        ),
      ],
    );
  }
}
