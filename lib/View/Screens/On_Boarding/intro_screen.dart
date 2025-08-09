import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/Utils/app_colors.dart';

class IntroductionScreenExample extends StatefulWidget {
  const IntroductionScreenExample({super.key});

  @override
  _IntroductionScreenExampleState createState() => _IntroductionScreenExampleState();
}

class _IntroductionScreenExampleState extends State<IntroductionScreenExample> 
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Setup animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animations
    _startAnimations();
    checkIntroSeenStatus();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  Future<void> checkIntroSeenStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool introSeen = prefs.getBool('introSeen') ?? false;

    if (introSeen) {
      context.go('/home');
    }
  }

  Future<void> markIntroAsSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('introSeen', true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          _buildBackground(screenSize, isDarkMode),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, screenSize),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          _buildPage(
                            "assets/lottie1.json",
                            "Never lose your valuable items again. Track, locate, and recover your belongings with ease. From keys to electronics, we help you find what matters most.",
                            "Welcome to ",
                            "My Lost",
                            " - Find Your Items",
                            isDarkMode,
                          ),
                          _buildPage(
                            "assets/lottie2.json",
                            "Report lost items with detailed descriptions and locations. Connect with people who find your belongings and help others recover their lost items too.",
                            "Smart ",
                            "Item Tracking",
                            " & Recovery System",
                            isDarkMode,
                          ),
                          _buildPage(
                            "assets/lottie3.json",
                            "Get instant notifications when someone finds your item. Build a community of helpers and never worry about losing your important belongings again.",
                            "Stay Connected ",
                            "Never Lose",
                            " Anything Again",
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildIndicatorAndButton(context, screenSize, isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(Size screenSize, bool isDarkMode) {
    // Responsive breakpoints
    final isTablet = screenSize.width > 600;
    final isLargeScreen = screenSize.width > 900;
    final isSmallScreen = screenSize.width < 400;
    
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background gradient that extends full screen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [
                        AppColors.darkBackgroundColor.withValues(alpha: 0.2),
                        AppColors.darkSurfaceColor.withValues(alpha: 0.6),
                        AppColors.darkBackgroundColor.withValues(alpha: 0.85),
                        AppColors.darkBackgroundColor,
                      ]
                    : [
                        AppColors.lightBackgroundColor.withValues(alpha: 0.2),
                        AppColors.lightSurfaceColor.withValues(alpha: 0.6),
                        AppColors.lightBackgroundColor.withValues(alpha: 0.85),
                        AppColors.lightBackgroundColor,
                      ],
                stops: const [0.0, 0.45, 0.75, 1.0],
              ),
            ),
          ),
          

          
          // Responsive decorative elements
          ...List.generate(3, (index) {
            final elementSize = isLargeScreen 
                ? 90.0 + index * 35 
                : isTablet 
                    ? 75.0 + index * 28 
                    : isSmallScreen
                        ? 50.0 + index * 18
                        : 65.0 + index * 22;
            
            final topPosition = isLargeScreen
                ? screenSize.height * (0.08 + index * 0.07)
                : isTablet
                    ? screenSize.height * (0.1 + index * 0.08)
                    : screenSize.height * (0.12 + index * 0.09);
            
            final rightPosition = isLargeScreen
                ? screenSize.width * (0.03 + index * 0.1)
                : isTablet
                    ? screenSize.width * (0.05 + index * 0.11)
                    : screenSize.width * (0.05 + index * 0.12);
            
            return Positioned(
              top: topPosition,
              right: rightPosition,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: elementSize,
                  height: elementSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDarkMode ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor)
                        .withValues(alpha: 0.06 - index * 0.015),
                  ),
                ),
              ),
            );
          }),
          
          // Additional floating elements for larger screens
          if (isTablet) ...[
            Positioned(
              top: screenSize.height * 0.2,
              left: screenSize.width * 0.08,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: isLargeScreen ? 50 : 40,
                  height: isLargeScreen ? 50 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDarkMode ? AppColors.darkSecondaryColor : AppColors.lightSecondaryColor)
                        .withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenSize.height * 0.32,
              left: screenSize.width * 0.82,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: isLargeScreen ? 35 : 28,
                  height: isLargeScreen ? 35 : 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDarkMode ? AppColors.darkAccentColor : AppColors.lightAccentColor)
                        .withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
          ],
          
          // Extra decorative elements for small screens
          if (isSmallScreen) ...[
            Positioned(
              top: screenSize.height * 0.18,
              left: screenSize.width * 0.15,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDarkMode ? AppColors.darkSecondaryColor : AppColors.lightSecondaryColor)
                        .withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size screenSize) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              ),
              child: TextButton(
                onPressed: () async {
                  await markIntroAsSeen();
                  context.go('/landing');
                },
                child: Text(
                  "Skip",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: screenSize.width * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(String lottieFile, String body, String title1, String title2, String title3, bool isDarkMode) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeScreen = screenSize.width > 900;
    final isSmallScreen = screenSize.width < 400;
    
    // Responsive sizing
    final horizontalPadding = isLargeScreen 
        ? screenSize.width * 0.12 
        : isTablet 
            ? screenSize.width * 0.08 
            : screenSize.width * 0.06;
    
    final lottieHeight = isLargeScreen 
        ? screenSize.height * 0.22 
        : isTablet 
            ? screenSize.height * 0.24 
            : isSmallScreen
                ? screenSize.height * 0.2
                : screenSize.height * 0.22;
    
    final lottieWidth = isLargeScreen 
        ? screenSize.width * 0.6 
        : isTablet 
            ? screenSize.width * 0.7 
            : screenSize.width * 0.8;
    
    final titleFontSize = isLargeScreen 
        ? screenSize.width * 0.05 
        : isTablet 
            ? screenSize.width * 0.055 
            : isSmallScreen
                ? screenSize.width * 0.065
                : screenSize.width * 0.07;
    
    final bodyFontSize = isLargeScreen 
        ? screenSize.width * 0.035 
        : isTablet 
            ? screenSize.width * 0.04 
            : isSmallScreen
                ? screenSize.width * 0.042
                : screenSize.width * 0.045;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation with responsive container
          Container(
            height: lottieHeight,
            width: lottieWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isLargeScreen ? 25 : 20),
              color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor)
                      .withOpacity(0.08),
                  blurRadius: isLargeScreen ? 25 : 20,
                  spreadRadius: isLargeScreen ? 3 : 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isLargeScreen ? 25 : 20),
              child: Lottie.asset(
                lottieFile, 
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          SizedBox(height: screenSize.height * (isLargeScreen ? 0.035 : 0.04)),
          
          // Responsive title with rich text
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 40 : isTablet ? 20 : 10,
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: title1,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w300,
                      height: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: title2,
                    style: TextStyle(
                      color: isDarkMode ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                      height: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: title3,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w300,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: screenSize.height * (isLargeScreen ? 0.025 : 0.03)),
          
          // Responsive description text
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 60 : isTablet ? 40 : 20,
            ),
            child: Text(
              body,
              style: TextStyle(
                fontSize: bodyFontSize,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: isLargeScreen ? 1.6 : 1.5,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: isSmallScreen ? 4 : null,
              overflow: isSmallScreen ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorAndButton(BuildContext context, Size screenSize, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.05),
      child: Column(
        children: [
          // Custom indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 30 : 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _currentPage == index
                      ? (isDarkMode ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor)
                      : (isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary).withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          SizedBox(height: screenSize.height * 0.03),
          
          // Custom button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode 
                    ? [AppColors.darkPrimaryColor, AppColors.darkSecondaryColor]
                    : [AppColors.lightPrimaryColor, AppColors.lightSecondaryColor],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor)
                      .withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: () async {
                if (_currentPage == 2) {
                  await markIntroAsSeen();
                  context.go('/landing');
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(
                _currentPage == 2 ? "Get Started" : "Next",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.045,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}