import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/main.dart';

@RoutePage()
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final authManager = await getIt.getAsync<AuthManager>();
    await authManager.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
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
        actions: [
          TextButton(
            onPressed: () => _handleLogout(context),
            child: const Text(
              'Exit',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile picture
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColorsDark.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 60, color: AppColorsDark.primary),
            ),
            const SizedBox(height: 24),

            // Name
            const Text(
              'Logan Jimmy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Email
            _ProfileField(label: 'Email', value: 'jim_logan01@gmail.com'),
            const SizedBox(height: 24),

            // Phone Number
            _ProfileField(label: 'Phone Number', value: '8844662200'),
            const SizedBox(height: 32),

            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(number: '120', label: 'songs'),
                _StatCard(number: '12', label: 'playlists'),
                _StatCard(number: '3', label: 'artists'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;

  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
