import 'package:flutter/material.dart';

import 'profile_avatar_widget.dart';

/// Molécula que combina el avatar y el nombre del perfil.
class ProfileHeaderMolecule extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final String initials;
  final double avatarSize;

  const ProfileHeaderMolecule({
    required this.displayName, required this.avatarUrl, required this.initials, super.key,
    this.avatarSize = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatarWidget(avatarUrl: avatarUrl, initials: initials),
        const SizedBox(height: 24),
        Text(
          displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
