import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import '../atoms/onboarding_button.dart';
import '../atoms/onboarding_subtitle.dart';
import '../atoms/onboarding_title.dart';

class OnboardingContent extends StatelessWidget {
  final String titleFirstPart;
  final String titleHighlightedPart;
  final String subtitle;
  final String buttonText;
  final bool isButtonLoading;
  final VoidCallback? onButtonPressed;

  const OnboardingContent({
    super.key,
    required this.titleFirstPart,
    required this.titleHighlightedPart,
    required this.subtitle,
    required this.buttonText,
    required this.isButtonLoading,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColorsDark.surface.withValues(alpha: 0.0),
            AppColorsDark.surface.withValues(alpha: 0.8),
            AppColorsDark.surface,
            AppColorsDark.surface,
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OnboardingTitle(
              firstPart: titleFirstPart,
              highlightedPart: titleHighlightedPart,
            ),
            const SizedBox(height: 16),
            OnboardingSubtitle(text: subtitle),
            const SizedBox(height: 40),
            OnboardingButton(
              onPressed: onButtonPressed,
              isLoading: isButtonLoading,
              text: buttonText,
            ),
          ],
        ),
      ),
    );
  }
}
