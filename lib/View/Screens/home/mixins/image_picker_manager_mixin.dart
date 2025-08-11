import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/Utils/app_colors.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../Widgets/home/image_picker_section_widget.dart';

mixin ImagePickerManagerMixin<T extends StatefulWidget> on State<T> {
  XFile? _selectedImage;

  XFile? get selectedImage => _selectedImage;

  Future<void> initializeImageService() async {
    try {
      await ImagePickerService.initialize();
      debugPrint('Image picker service initialized successfully');
    } catch (e) {
      debugPrint('Image picker service initialization failed: $e');
    }
  }

  Future<void> pickImage({ImageSource source = ImageSource.camera}) async {
    final isHealthy = await ImagePickerService.isServiceHealthy();
    if (!isHealthy) {
      debugPrint('Image picker service not healthy, attempting reset');
      try {
        await ImagePickerService.reset();
      } catch (e) {
        debugPrint('Service reset failed: $e');
      }
    }

    _showLoadingSnackBar();

    try {
      debugPrint('ReportScreen: Starting image picker for $source');
      
      final XFile? image = await ImagePickerService.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      _dismissLoadingSnackBar();

      if (image != null) {
        // Validate file size before setting (following file_upload_widget.dart standards)
        final file = File(image.path);
        final fileSize = await file.length();
        final formattedSize = CloudinaryService.formatFileSize(fileSize);
        
        debugPrint('📏 Selected image size: $fileSize bytes ($formattedSize)');
        
        // Check if file size is valid
        if (!CloudinaryService.isValidImageSize(fileSize)) {
          final maxSizeFormatted = CloudinaryService.formatFileSize(CloudinaryService.maxImageSizeBytes);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Image size ($formattedSize) exceeds $maxSizeFormatted limit. Please select a smaller image.'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return; // Don't set the image if it's too large
        }
        
        setState(() => _selectedImage = image);
        await _showSuccessMessage(image);
      } else {
        _showNoImageSelectedMessage();
      }
    } catch (e) {
      debugPrint('ReportScreen: Image picker error: $e');
      _dismissLoadingSnackBar();
      if (mounted) {
        _showImagePickerErrorDialog(source, e.toString());
      }
    }
  }

  void _showLoadingSnackBar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Opening camera/gallery...'),
            ],
          ),
          backgroundColor: AppColors.lightPrimaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  void _dismissLoadingSnackBar() {
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    }
  }

  Future<void> _showSuccessMessage(XFile image) async {
    final file = File(image.path);
    final int fileSize = await file.length();
    final formattedSize = CloudinaryService.formatFileSize(fileSize);
    
    if (mounted) {
      // Enhanced success message following file_upload_widget.dart standards
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Image selected: ${image.name} | Size: $formattedSize'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Enhanced logging following file_upload_widget.dart standards
      debugPrint('📄 Image selected successfully: ${image.name} | Size: $formattedSize | Path: ${image.path}');
    }
  }

  void _showNoImageSelectedMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image selected'),
          backgroundColor: Colors.grey,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showImagePickerErrorDialog(ImageSource source, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Camera/Gallery Issue'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              source == ImageSource.camera 
                ? 'Camera access failed. This might be due to:'
                : 'Gallery access failed. This might be due to:',
            ),
            const SizedBox(height: 8),
            const Text(
              '• iOS system permissions\n'
              '• App needs restart\n'
              '• Plugin initialization issues',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Text('What would you like to try?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted) {
                pickImage(
                  source: source == ImageSource.camera 
                    ? ImageSource.gallery 
                    : ImageSource.camera
                );
              }
            },
            child: Text(source == ImageSource.camera ? 'Try Gallery' : 'Try Camera'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resetting camera service...'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
              
              try {
                await ImagePickerService.reset();
                await Future.delayed(const Duration(milliseconds: 500));
                if (mounted) {
                  pickImage(source: source);
                }
              } catch (e) {
                debugPrint('Service reset retry failed: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset & Retry'),
          ),
        ],
      ),
    );
  }

  void showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceBottomSheet(
        onCameraSelected: () => pickImage(source: ImageSource.camera),
        onGallerySelected: () => pickImage(source: ImageSource.gallery),
      ),
    );
  }
}