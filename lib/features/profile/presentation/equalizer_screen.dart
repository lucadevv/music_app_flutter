import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/profile/profile_cubit.dart';
import 'package:music_app/main.dart';

@RoutePage()
class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  final List<Map<String, dynamic>> _presets = [
    {'id': 'flat', 'name': 'Flat', 'description': 'No modification'},
    {'id': 'rock', 'name': 'Rock', 'description': 'Enhanced bass and treble'},
    {'id': 'pop', 'name': 'Pop', 'description': 'Balanced for vocals'},
    {'id': 'jazz', 'name': 'Jazz', 'description': 'Warm and smooth'},
    {'id': 'classical', 'name': 'Classical', 'description': 'Clear and detailed'},
    {'id': 'electronic', 'name': 'Electronic', 'description': 'Punchy bass'},
    {'id': 'bass_boost', 'name': 'Bass Boost', 'description': 'Maximum bass'},
    {'id': 'treble_boost', 'name': 'Treble Boost', 'description': 'Enhanced highs'},
    {'id': 'vocal', 'name': 'Vocal', 'description': 'Clear voice'},
    {'id': 'custom', 'name': 'Custom', 'description': 'Your settings'},
  ];

  String? _selectedPreset;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPreset();
  }

  void _loadCurrentPreset() {
    final profileCubit = getIt<ProfileCubit>();
    setState(() {
      _selectedPreset = profileCubit.state.settings?.equalizerPreset ?? 'flat';
    });
  }

  Future<void> _selectPreset(String presetId) async {
    setState(() {
      _isLoading = true;
      _selectedPreset = presetId;
    });

    try {
      final profileCubit = getIt<ProfileCubit>();
      await profileCubit.updateEqualizerPreset(presetId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preset: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColorsDark.primary,
              ),
            )
          : ListView.builder(
              itemCount: _presets.length,
              itemBuilder: (context, index) {
                final preset = _presets[index];
                final isSelected = _selectedPreset == preset['id'];

                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.equalizer : Icons.equalizer_outlined,
                    color: isSelected ? AppColorsDark.primary : Colors.white,
                  ),
                  title: Text(
                    preset['name'],
                    style: TextStyle(
                      color: isSelected ? AppColorsDark.primary : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                  onTap: () => _selectPreset(preset['id']),
                );
              },
            ),
    );
  }
}
