import 'package:flutter/material.dart';
import 'package:music_app/core/utils/format_utils.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';

import '../animators/animated_profile_field_widget.dart';
import '../molecules/profile_field_widget.dart';

/// Organismo que reune la información confidencial (Email, Provider, Creado) de Perfil
class ProfileInfoSectionWidget extends StatelessWidget {
  final ProfileState state;

  const ProfileInfoSectionWidget({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        AnimatedProfileFieldWidget(
          delay: 0.1,
          child: ProfileFieldWidget(
            label: l10n.email,
            value: state.email,
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedProfileFieldWidget(
          delay: 0.2,
          child: ProfileFieldWidget(
            label: l10n.provider,
            value: state.provider.toUpperCase(),
            icon: Icons.login,
          ),
        ),
        const SizedBox(height: 16),
        if (state.createdAt != null)
          AnimatedProfileFieldWidget(
            delay: 0.3,
            child: ProfileFieldWidget(
              label: l10n.memberSince,
              value: FormatUtils.date(state.createdAt!, months),
              icon: Icons.calendar_today_outlined,
            ),
          ),
      ],
    );
  }
}
