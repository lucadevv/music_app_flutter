import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';

@RoutePage()
class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ProfileCubit es singleton, ya está proporcionado en app.dart
    return const _EqualizerView();
  }
}

class _EqualizerView extends StatelessWidget {
  const _EqualizerView();

  static const List<Map<String, dynamic>> _presets = [
    {'id': 'flat', 'name': 'Flat', 'description': 'No modification'},
    {'id': 'rock', 'name': 'Rock', 'description': 'Enhanced bass and treble'},
    {'id': 'pop', 'name': 'Pop', 'description': 'Balanced for vocals'},
    {'id': 'jazz', 'name': 'Jazz', 'description': 'Warm and smooth'},
    {
      'id': 'classical',
      'name': 'Classical',
      'description': 'Clear and detailed',
    },
    {'id': 'electronic', 'name': 'Electronic', 'description': 'Punchy bass'},
    {'id': 'bass_boost', 'name': 'Bass Boost', 'description': 'Maximum bass'},
    {
      'id': 'treble_boost',
      'name': 'Treble Boost',
      'description': 'Enhanced highs',
    },
    {'id': 'vocal', 'name': 'Vocal', 'description': 'Clear voice'},
    {'id': 'custom', 'name': 'Custom', 'description': 'Your settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final selectedPreset = state.settings?.equalizerPreset ?? 'flat';

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Equalizer',
              style: TextStyle(
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
          body: ListView.builder(
            itemCount: _presets.length,
            itemBuilder: (context, index) {
              final preset = _presets[index];
              final isSelected = selectedPreset == preset['id'];

              return ListTile(
                leading: Icon(
                  isSelected ? Icons.equalizer : Icons.equalizer_outlined,
                  color: isSelected ? AppColorsDark.primary : Colors.white,
                ),
                title: Text(
                  preset['name'],
                  style: TextStyle(
                    color: isSelected ? AppColorsDark.primary : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  preset['description'],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColorsDark.primary)
                    : null,
                onTap: () => _selectPreset(context, preset['id']),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _selectPreset(BuildContext context, String presetId) async {
    try {
      await context.read<ProfileCubit>().updateEqualizerPreset(presetId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving preset: $e')));
      }
    }
  }
}
