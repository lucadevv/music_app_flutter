import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/locale_cubit.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

/// Widget reutilizable for seleccionar idioma
class LanguageSelector extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;

  const LanguageSelector({super.key, this.backgroundColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final currentLocale = state.locale;
        final isSpanish = currentLocale.languageCode == 'es';

        return Container(
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                AppColorsDark.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageButton(
                label: 'EN',
                isSelected: !isSpanish,
                onTap: () => _changeLanguage(context, 'en'),
                textColor: textColor,
              ),
              _LanguageButton(
                label: 'ES',
                isSelected: isSpanish,
                onTap: () => _changeLanguage(context, 'es'),
                textColor: textColor,
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    // Usar el contexto para obtener el cubit del árbol de widgets (ya provisto en app.dart)
    try {
      final localeCubit = context.read<LocaleCubit>();
      localeCubit.setLocaleByCode(languageCode);
    } catch (e) {
      // Fallback: obtener de getIt si no está en el contexto
      // No longer needed - LocaleCubit is now provided via BlocProvider in app.dart
    }
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? textColor;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColorsDark.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (textColor ?? AppColorsDark.surfaceDim)
                : (textColor ?? AppColorsDark.onSurface),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
