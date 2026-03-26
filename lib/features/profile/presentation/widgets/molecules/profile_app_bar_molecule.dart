import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Molécula que muestra el AppBar del perfil con título, botón de back y acciones.
class ProfileAppBarMolecule extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onLogout;
  final String? logoutText;

  const ProfileAppBarMolecule({
    required this.title,
    required this.onBack,
    super.key,
    this.onLogout,
    this.logoutText,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColorsDark.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColorsDark.onSurface,
        ),
        onPressed: onBack,
      ),
      actions: [
        if (onLogout != null)
          TextButton(
            onPressed: onLogout,
            child: Text(
              logoutText ?? l10n.exit,
              style: const TextStyle(color: AppColorsDark.error, fontSize: 16),
            ),
          ),
      ],
    );
  }
}
