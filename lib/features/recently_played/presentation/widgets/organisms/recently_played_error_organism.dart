import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/features/recently_played/presentation/cubit/recently_played_cubit.dart';

class RecentlyPlayedErrorOrganism extends StatelessWidget {
  final String? errorMessage;

  const RecentlyPlayedErrorOrganism({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? l10n.errorLoadingSongs,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<RecentlyPlayedCubit>().loadRecentlyPlayed(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsDark.primary,
            ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
