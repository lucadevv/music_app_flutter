import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/services/local/onboarding_service.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

import 'organisms/background_layer.dart';
import 'organisms/onboarding_content.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  bool _isCompleting = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboardingAndNavigate() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    try {
      final onboardingService = getIt<OnboardingService>();
      await onboardingService.setOnboardingCompleted(true);

      if (mounted) {
        await context.router.push(const SocialLoginRoute());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColorsDark.surface,
      body: Stack(
        children: [
          BackgroundLayer(fadeAnimation: _fadeAnimation),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: OnboardingContent(
                titleFirstPart: '${l10n.diveIntoYour}\n',
                titleHighlightedPart: l10n.vibeat,
                subtitle: l10n.onboardingSubtitle,
                buttonText: l10n.startExplore,
                isButtonLoading: _isCompleting,
                onButtonPressed: _isCompleting
                    ? null
                    : _completeOnboardingAndNavigate,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const LanguageSelector(),
            ),
          ),
        ],
      ),
    );
  }
}
