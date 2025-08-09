import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/Utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _textController;
  
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _textAnimation;
  late Animation<Offset> _logoSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Setup animations
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _startAnimations();
    _navigateToNextScreen();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _backgroundController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 1200));
    _textController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool introSeen = prefs.getBool('introSeen') ?? false;

    await Future.delayed(const Duration(seconds: 4));

    if (introSeen) {
      if (mounted) GoRouter.of(context).go('/home');
    } else {
      if (mounted) GoRouter.of(context).go('/intro');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    _textController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    AppColors.darkBackgroundColor,
                    AppColors.darkSurfaceColor,
                    AppColors.darkCardColor,
                  ]
                : [
                    AppColors.lightBackgroundColor,
                    AppColors.lightSurfaceColor,
                    Colors.white,
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Modern geometric background elements
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Positioned(
                  top: screenSize.height * 0.15 * _backgroundAnimation.value,
                  right: -50 * _backgroundAnimation.value,
                  child: Transform.rotate(
                    angle: 0.3 * _backgroundAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gradientStart.withOpacity(0.1),
                            AppColors.gradientMiddle.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Positioned(
                  bottom: screenSize.height * 0.1 * _backgroundAnimation.value,
                  left: -80 * _backgroundAnimation.value,
                  child: Transform.rotate(
                    angle: -0.2 * _backgroundAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            AppColors.gradientEnd.withOpacity(0.08),
                            AppColors.gradientStart.withOpacity(0.03),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Modern logo container
                    SlideTransition(
                      position: _logoSlideAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35),
                              color: isDarkMode 
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.white.withOpacity(0.25),
                              border: Border.all(
                                color: isDarkMode 
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode 
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: isDarkMode 
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.white.withOpacity(0.3),
                                  blurRadius: 40,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(33),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: Image.asset(
                                    'assets/Logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Modern app name and slogan
                    FadeTransition(
                      opacity: _textAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(_textController),
                        child: Column(
                          children: [
                            Text(
                              'My Lost',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode 
                                    ? AppColors.darkTextPrimary 
                                    : AppColors.lightTextPrimary,
                                letterSpacing: -1,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'To find your lost items',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode 
                                    ? AppColors.darkTextSecondary 
                                    : AppColors.lightTextSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                    
                    // Modern loading indicator
                    FadeTransition(
                      opacity: _textAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isDarkMode 
                              ? AppColors.darkSurfaceColor.withOpacity(0.8)
                              : AppColors.lightSurfaceColor.withOpacity(0.9),
                          border: Border.all(
                            color: isDarkMode 
                                ? AppColors.darkDividerColor
                                : AppColors.lightDividerColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDarkMode 
                                      ? AppColors.darkPrimaryColor
                                      : AppColors.lightPrimaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode 
                                    ? AppColors.darkTextSecondary 
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Modern bottom branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textAnimation,
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            (isDarkMode 
                                ? AppColors.darkTextSecondary 
                                : AppColors.lightTextSecondary)
                                .withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Never lose anything again',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode 
                            ? AppColors.darkTextSecondary 
                            : AppColors.lightTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
