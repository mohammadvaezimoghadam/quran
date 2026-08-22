import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/constants/app_constants.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnimation);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(curvedAnimation);

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToHome();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() async {
    if (mounted) {
      try {
        precacheImage(const AssetImage(AppConstants.ayahCardBgAsset), context);
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      context.goNamed(mainHomeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A), // Dark charcoal
              Color(0xFF000000), // Pure black
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        'تفکر',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn', // Changed to Vazirmatn
                          fontSize: 52,
                          color: Colors.white, // Changed to white
                          height: 1.4,
                          shadows: [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.2), // Subtle white glow
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // Minimal Gold Progress Indicator at Bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 36,
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

