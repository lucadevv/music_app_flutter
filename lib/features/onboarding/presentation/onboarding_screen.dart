import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/services/local/onboarding_service.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/language_selector.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
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
    Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColorsDark.surface,
      body: Stack(
        children: [


          // 1. Background Grid of Images (Masonry-like)
          Positioned(
            top: -50,
            left: -20,
            right: -20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.rotate(
                angle: -0.05,
                child: _buildImageGrid(),
              ),
            ),
          ),

          // 2. Bottom Content Gradient and Texts
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
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
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            height: 1.1,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(text: '${l10n.diveIntoYour}\n'),
                            TextSpan(
                              text: l10n.vibeat,
                              style: const TextStyle(color: AppColorsDark.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.onboardingSubtitle,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontFamily: 'Poppins',
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isCompleting ? null : _completeOnboardingAndNavigate,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isCompleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  l10n.startExplore,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
                    // Language Selector
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

  Widget _buildImageGrid() {
    return const SizedBox(
      height: 550,
      child: SingleChildScrollView(
        physics:  NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GridImage(url: 'https://images.unsplash.com/photo-1493225457124-a1a2a5f5f4a4?q=80&w=400&fit=crop', height: 160),
                 SizedBox(height: 12),
                _GridImage(url: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?q=80&w=400&fit=crop', height: 200),
                 SizedBox(height: 12),
                _GridImage(url: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=400&fit=crop', height: 150),
              ],
            ),
             SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 SizedBox(height: 60),
                _GridImage(url: 'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?q=80&w=400&fit=crop', height: 200),
                 SizedBox(height: 12),
                _GridImage(url: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?q=80&w=400&fit=crop', height: 170),
              ],
            ),
             SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 SizedBox(height: 20),
                _GridImage(url: 'https://images.unsplash.com/photo-1501612780327-45045538702b?q=80&w=400&fit=crop', height: 170),
                 SizedBox(height: 12),
                _GridImage(url: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=400&fit=crop', height: 210),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GridImage extends StatelessWidget {
  final String url;
  final double height;

  const _GridImage({required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: height,
      decoration: BoxDecoration(
        color: AppColorsDark.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: AppColorsDark.surfaceContainerHigh),
          errorWidget: (context, url, error) => const Icon(Icons.music_note, color: Colors.grey),
        ),
      ),
    );
  }
}
