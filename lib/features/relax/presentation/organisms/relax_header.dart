import 'package:flutter/material.dart';
import 'package:music_app/features/relax/presentation/atoms/app_text_styles.dart';
import 'package:music_app/l10n/app_localizations.dart';

class RelaxHeader extends StatelessWidget {
  const RelaxHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('👋 ${l10n.hi}', style: RelaxTextStyles.greeting),
          const SizedBox(height: 4),
          Text(l10n.goodEvening, style: RelaxTextStyles.title),
        ],
      ),
    );
  }
}
