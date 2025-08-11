import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/Utils/app_colors.dart';

class SubmitButtonWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSubmit;

  const SubmitButtonWidget({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: isLoading ? null : onSubmit,
        icon: const Icon(
          Iconsax.send_1,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          'Submit Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}