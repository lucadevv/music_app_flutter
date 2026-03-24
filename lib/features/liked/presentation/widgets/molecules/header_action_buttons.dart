import 'package:flutter/material.dart';
import 'package:music_app/features/liked/presentation/widgets/atoms/action_icon_button.dart';

class HeaderActionButtons extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onMoreTap;

  const HeaderActionButtons({super.key, this.onSearchTap, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionIconButton(icon: Icons.search, onTap: onSearchTap),
        ActionIconButton(icon: Icons.more_vert, onTap: onMoreTap),
      ],
    );
  }
}
