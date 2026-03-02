import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/services/local/onboarding_service.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  late List<OnboardingPageData> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _pages = [
      OnboardingPageData(
        title: l10n.discoverNewMusic,
        description: l10n.discoverNewMusicDesc,
        icon: Icons.music_note,
      ),
      OnboardingPageData(
        title: l10n.createYourPlaylists,
        description: l10n.createYourPlaylistsDesc,
        icon: Icons.playlist_add,
      ),
      OnboardingPageData(
        title: l10n.listenWithoutLimits,
        description: l10n.listenWithoutLimitsDesc,
        icon: Icons.headphones,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboardingAndNavigate() async {
    if (_isCompleting) return;
    
    setState(() => _isCompleting = true);
    
    try {
      final onboardingService = getIt<OnboardingService>();
      await onboardingService.setOnboardingCompleted(true);
      
      if (mounted) {
        context.router.push(const SocialLoginRoute());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboardingAndNavigate();
    }
  }

  void _skip() {
    _completeOnboardingAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColorsDark.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _isCompleting ? null : _skip,
                  child: Text(
                    l10n.skip,
                    style: TextStyle(
                      color: _isCompleting 
                          ? AppColorsDark.onSurfaceVariant.withValues(alpha: 0.5)
                          : AppColorsDark.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageWidget(page: _pages[index]);
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => PageIndicator(isActive: index == _currentPage),
              ),
            ),

            const SizedBox(height: 32),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isCompleting ? null : _nextPage,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorsDark.primary,
                    foregroundColor: AppColorsDark.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isCompleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _currentPage == _pages.length - 1
                              ? l10n.getStarted
                              : l10n.next,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageData page;

  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              color: AppColorsDark.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 100, color: AppColorsDark.primary),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColorsDark.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColorsDark.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final bool isActive;

  const PageIndicator({required this.isActive, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColorsDark.primary : AppColorsDark.outlineVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
