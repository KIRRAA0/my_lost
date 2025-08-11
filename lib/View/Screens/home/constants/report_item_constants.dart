import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ReportItemConstants {
  static const List<String> categories = [
    'Electronics',
    'Personal Items',
    'Documents',
    'Jewelry',
    'Clothing',
    'Bags',
    'Keys',
    'Other'
  ];

  static const Map<String, IconData> categoryIcons = {
    'Electronics': Iconsax.mobile,
    'Personal Items': Iconsax.personalcard,
    'Documents': Iconsax.document,
    'Jewelry': Iconsax.crown,
    'Clothing': Iconsax.crown,
    'Bags': Iconsax.bag,
    'Keys': Iconsax.key,
    'Other': Iconsax.category_2
  };

  static const String defaultCategory = 'Electronics';
  static const double cardSpacing = 24.0;
  static const double sectionSpacing = 32.0;
  
  // Image processing constants (aligned with CloudinaryService standards)
  static const int imageQuality = 85;
  static const double maxImageWidth = 1024;
  static const double maxImageHeight = 1024;
  
  // File size limits (following file_upload_widget.dart standards)
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB for images
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB for documents
}