import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../Common/custom_text_field.dart';

class FinderInformationFormWidget extends StatelessWidget {
  final TextEditingController finderNameController;
  final TextEditingController finderEmailController;
  final TextEditingController finderPhoneController;

  const FinderInformationFormWidget({
    super.key,
    required this.finderNameController,
    required this.finderEmailController,
    required this.finderPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Finder Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: finderNameController,
          labelText: 'Your Name',
          hintText: 'Enter your full name',
          icon: Iconsax.user,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: finderEmailController,
          labelText: 'Email Address',
          hintText: 'Enter your email address',
          icon: Iconsax.sms,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email address';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: finderPhoneController,
          labelText: 'Phone Number (Optional)',
          hintText: 'Enter your phone number',
          icon: Iconsax.call,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}