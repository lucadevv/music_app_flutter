// ignore_for_file: unnecessary_underscores
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';

import 'widgets/atoms/profile_avatar_atom.dart';
import 'widgets/atoms/settings_item_atom.dart';
import 'widgets/molecules/settings_section_molecule.dart';
import 'widgets/organisms/profile_loading_organism.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ProfileCubit es singleton, ya está proporcionado en app.dart
    // Cargar perfil al entrar si no está cargado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileCubit = context.read<ProfileCubit>();
      if (!profileCubit.state.isLoading && profileCubit.state.profile == null) {
        profileCubit.loadProfile();
      }
    });
    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.profileAndSettings,
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
        builder: (context, state) {
          if (state.isLoading) {
            return const ProfileLoadingOrganism();
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Profile header - clickeable para ir a My Profile
              _ProfileHeader(
                displayName: state.displayName,
                email: state.email,
                avatarUrl: state.avatarUrl,
                initials: state.initials,
              ),

              // Settings section
              SettingsSectionMolecule(
                title: l10n.settings,
                items: [
                  SettingsItemAtom(
                    icon: Icons.settings,
                    title: l10n.settings,
                    onTap: () {
                      context.router.push(const SettingsRoute());
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

/// Organismo que muestra el header del perfil con avatar, nombre y email.
class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String initials;

  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.router.push(const MyProfileRoute());
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            ProfileAvatarAtom(
              avatarUrl: avatarUrl,
              initials: initials,
              size: 80,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
