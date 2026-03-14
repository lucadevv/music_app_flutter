// ignore_for_file: deprecated_member_use
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

@RoutePage()
class StreamingQualityScreen extends StatelessWidget {
  const StreamingQualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final qualities = [
      {'name': 'Low', 'description': 'Save data'},
      {'name': 'Normal', 'description': 'Balanced quality'},
      {'name': 'High', 'description': 'Best quality'},
      {'name': 'Very High', 'description': 'Maximum quality'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Streaming Quality',
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
        itemCount: qualities.length,
        itemBuilder: (context, index) {
          final quality = qualities[index];
          final isSelected = index == 2; // High selected
          return RadioListTile<String>(
            value: quality['name']!,
            groupValue: isSelected ? quality['name'] : null,
            onChanged: (value) {},
            title: Text(
              quality['name']!,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              quality['description']!,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
            activeColor: AppColorsDark.primary,
            selected: isSelected,
          );
        },
      ),
    );
  }
}
