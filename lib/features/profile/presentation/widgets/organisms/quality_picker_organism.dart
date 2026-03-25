// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';

class QualityPickerOrganism extends StatelessWidget {
  final String type;
  final String currentQuality;

  const QualityPickerOrganism({
    required this.type, required this.currentQuality, super.key,
  });

  static const List<String> _qualities = ['low', 'medium', 'high', 'hd', 'uhd'];

  static String getQualityName(String quality) {
    final names = {
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'hd': 'HD',
      'uhd': 'UHD',
    };
    return names[quality] ?? quality;
  }

  static String getEqualizerName(String preset) {
    final names = {
      'flat': 'Flat',
      'rock': 'Rock',
      'pop': 'Pop',
      'bass_boost': 'Bass Boost',
      'treble_boost': 'Treble Boost',
      'vocal': 'Vocal',
      'classical': 'Classical',
      'jazz': 'Jazz',
      'electronic': 'Electronic',
      'custom': 'Custom',
    };
    return names[preset] ?? preset;
  }

  static String getLanguageName(String code) {
    final names = {
      'en': 'English',
      'es': 'Español',
      'pt': 'Português',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'ja': '日本語',
      'ko': '한국어',
      'zh': '中文',
    };
    return names[code] ?? code;
  }

  static void show(BuildContext context, String type, String currentQuality) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (ctx) =>
          QualityPickerOrganism(type: type, currentQuality: currentQuality),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _qualities.length,
      itemBuilder: (context, index) {
        final quality = _qualities[index];
        final isSelected = quality == currentQuality;

        return RadioListTile<String>(
          value: quality,
          groupValue: currentQuality,
          onChanged: (value) {
            if (value != null) {
              if (type == 'streaming') {
                context.read<ProfileCubit>().updateStreamingQuality(value);
              } else {
                context.read<ProfileCubit>().updateDownloadQuality(value);
              }
              Navigator.pop(context);
            }
          },
          title: Text(
            getQualityName(quality),
            style: const TextStyle(color: Colors.white),
          ),
          activeColor: AppColorsDark.primary,
          selected: isSelected,
        );
      },
    );
  }
}
