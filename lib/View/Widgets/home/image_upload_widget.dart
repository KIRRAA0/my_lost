import 'dart:io';
import 'dart:math' show log, pow;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/Utils/app_colors.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? storageKey;
  final String? initialFileName;
  final String? initialFilePath;
  final bool isDarkMode;
  final ValueChanged<String?>? onImageUploaded; // Callback for when image is uploaded

  const ImageUploadWidget({
    super.key,
    this.storageKey,
    this.initialFileName,
    this.initialFilePath,
    required this.isDarkMode,
    this.onImageUploaded,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  String fileName = '';
  String filePath = ''; // This will store the Cloudinary URL
  bool isUploading = false;
  String originalSize = '';

  // Use the same Cloudinary config as your existing service
  final cloudinary = Cloudinary.signedConfig(
    apiKey: '627342453218689',
    apiSecret: 'CH1szCiZ00_urjior8eqvnMyZQg',
    cloudName: 'do678okpb',
  );

  @override
  void initState() {
    super.initState();
    if (widget.initialFileName?.isNotEmpty ?? false) {
      fileName = widget.initialFileName!;
      filePath = widget.initialFilePath!;
    }
  }

  String formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          isUploading = true;
        });
        
        File file = File(image.path);

        // Get file size
        final fileBytes = file.lengthSync();
        originalSize = formatSize(fileBytes);
        fileName = image.name;

        // Check file size (limit to 5MB for images)
        if (fileBytes > 5 * 1024 * 1024) {
          throw Exception('Image size exceeds 5MB limit');
        }

        try {
          debugPrint('📤 Starting Cloudinary upload for: $fileName');
          debugPrint('📏 File size: $originalSize');
          
          // Upload to Cloudinary
          final response = await cloudinary.upload(
            file: file.path,
            resourceType: CloudinaryResourceType.image,
            folder: 'lost-items',
          );

          // Check for errors in the response
          if (response.isSuccessful && response.secureUrl != null) {
            setState(() {
              filePath = response.secureUrl!;
            });
            
            debugPrint('🎉 Image uploaded successfully: $fileName | Size: $originalSize | URL: $filePath');
            
            // Notify parent widget
            widget.onImageUploaded?.call(filePath);
            
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Image uploaded successfully!')),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            debugPrint('❌ Cloudinary upload failed: ${response.error}');
            throw Exception('Cloudinary upload failed: ${response.error}');
          }
        } catch (error) {
          debugPrint('💥 Detailed error during image upload: $error');
          rethrow;
        }
      }
    } catch (error) {
      debugPrint('❌ Error during image upload: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Upload failed: ${error.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ImageSourceOption(
                    icon: Iconsax.camera,
                    title: 'Camera',
                    subtitle: 'Take a photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(context, ImageSource.camera);
                    },
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ImageSourceOption(
                    icon: Iconsax.gallery,
                    title: 'Gallery',
                    subtitle: 'Choose from gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(context, ImageSource.gallery);
                    },
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Photo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        isUploading
            ? Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  color: widget.isDarkMode ? Colors.grey[850] : Colors.grey[50],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.lightPrimaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Uploading image...',
                      style: TextStyle(
                        color: AppColors.lightPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : filePath.isEmpty
              ? GestureDetector(
                  onTap: () => _showImageSourceDialog(context),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      color: widget.isDarkMode ? Colors.grey[850] : Colors.grey[50],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Iconsax.camera,
                            size: 32,
                            color: AppColors.lightPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to capture photo',
                          style: TextStyle(
                            color: AppColors.lightPrimaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Clear photo helps identify the item',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Image preview (using network image since we have the URL)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              filePath,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: double.infinity,
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.error_outline),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Iconsax.camera,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Image info
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    originalSize,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: AppColors.lightPrimaryColor,
                                  ),
                                  onPressed: () => _showImageSourceDialog(context),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      fileName = '';
                                      filePath = '';
                                      originalSize = '';
                                    });
                                    widget.onImageUploaded?.call(null);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      ],
    );
  }

  // Getter for the Cloudinary URL (to be used by the form)
  String? get cloudinaryUrl => filePath.isEmpty ? null : filePath;
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _ImageSourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDarkMode ? Colors.grey[800] : Colors.white,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.lightPrimaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}