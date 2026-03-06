import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  bool _isCompleting = false;

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
    // We use hardcoded texts as per the design to show the visual, 
    // but ideally these should be in AppLocalizations.
    return Scaffold(
      backgroundColor: AppColorsDark.surface,
      body: Stack(
        children: [
          // 1. Background Grid of Images (Masonry-like)
          Positioned(
            top: -50,
            left: -20,
            right: -20,
            child: Transform.rotate(
              angle: -0.05,
              child: _buildImageGrid(),
            ),
          ),

          // 2. Bottom Content Gradient and Texts
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
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
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          height: 1.1,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'Dive Into Your\n'),
                          TextSpan(
                            text: 'RhythmoTune.',
                            style: TextStyle(color: AppColorsDark.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Experience seamless music enjoyment,\ncrafted for every moment.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColorsDark.onSurfaceVariant,
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
                            : const Text(
                                'Start Explore',
                                style: TextStyle(
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
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return const SizedBox(
      height: 600,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              _GridImage(url: 'https://images.unsplash.com/photo-1493225457124-a1a2a5f5f4a4?q=80&w=400&fit=crop', height: 180),
              SizedBox(height: 16),
              _GridImage(url: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?q=80&w=400&fit=crop', height: 240),
              SizedBox(height: 16),
              _GridImage(url: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=400&fit=crop', height: 180),
            ],
          ),
          const SizedBox(height: 16),
          const Column(
            children: [
              SizedBox(height: 80),
              _GridImage(url: 'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?q=80&w=400&fit=crop', height: 240),
              SizedBox(height: 16),
              _GridImage(url: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?q=80&w=400&fit=crop', height: 200),
            ],
          ),
          const SizedBox(width: 16),
          const Column(
            children: [
              SizedBox(height: 30),
              _GridImage(url: 'https://images.unsplash.com/photo-1501612780327-45045538702b?q=80&w=400&fit=crop', height: 200),
              SizedBox(height: 16),
              _GridImage(url: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=400&fit=crop', height: 250),
            ],
          ),
        ],
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
      width: 130,
      height: height,
      decoration: BoxDecoration(
        color: AppColorsDark.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
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
