import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/locale_cubit.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/profile/profile_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCubit = getIt<LocaleCubit>();
    final profileCubit = getIt<ProfileCubit>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.language,
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
      body: BlocBuilder<LocaleCubit, LocaleState>(
        bloc: localeCubit,
        builder: (context, state) {
          return ListView.builder(
            itemCount: LocaleCubit.supportedLocales.length,
            itemBuilder: (context, index) {
              final locale = LocaleCubit.supportedLocales[index];
              final isSelected = state.locale.languageCode == locale.languageCode;
              final localeName = LocaleCubit.localeNames[locale.languageCode] ?? locale.languageCode;
              
              return RadioListTile<String>(
                value: locale.languageCode,
                groupValue: state.locale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    localeCubit.setLocaleByCode(value);
                    // Also update in backend
                    profileCubit.updateLanguage(value);
                  }
                },
                title: Text(
                  localeName,
                  style: const TextStyle(color: Colors.white),
                ),
                activeColor: AppColorsDark.primary,
                selected: isSelected,
              );
            },
          );
        },
      ),
    );
  }
}
