import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/l10n/app_localizations.dart';
import '../cubit/mood_genre_cubit.dart';

/// Widget para mostrar el estado de error
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar el estado de error y permitir reintentar
class MoodGenreErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final String params;

  const MoodGenreErrorWidget({
    required this.params, super.key,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage ?? l10n.errorLoadingPlaylists,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MoodGenreCubit>().loadMoodPlaylists(params);
            },
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
