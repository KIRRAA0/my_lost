import 'package:flutter/material.dart';

mixin ReportScreenAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController slideAnimationController;
  late AnimationController fadeAnimationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  void initializeAnimations() {
    slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideAnimationController,
      curve: Curves.easeOutBack,
    ));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeAnimationController,
      curve: Curves.easeIn,
    ));

    fadeAnimationController.forward();
    slideAnimationController.forward();
  }

  void disposeAnimations() {
    slideAnimationController.dispose();
    fadeAnimationController.dispose();
  }

  Widget buildAnimatedContent({required Widget child}) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}