import 'dart:io';
import 'dart:math' show log, pow;

import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _cloudName = 'do678okpb';
  static const String _apiKey = '627342453218689';
  static const String _apiSecret = 'CH1szCiZ00_urjior8eqvnMyZQg';

  static late Cloudinary _cloudinary;
  static bool _isInitialized = false;
  
  // File size constants (following file_upload_widget.dart standards)
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB limit
  static const int maxImageSizeBytes = 5 * 1024 * 1024;  // 5MB limit for images

  /// Format file size in human readable format (following file_upload_widget.dart standards)
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Validate image file size before upload
  static bool isValidImageSize(int bytes) {
    return bytes <= maxImageSizeBytes;
  }

  /// Validate general file size before upload  
  static bool isValidFileSize(int bytes) {
    return bytes <= maxFileSizeBytes;
  }

  /// Initialize Cloudinary service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _cloudinary = Cloudinary.signedConfig(
        apiKey: _apiKey,
        apiSecret: _apiSecret,
        cloudName: _cloudName,
      );
      
      _isInitialized = true;
      debugPrint('CloudinaryService: Initialized successfully');
    } catch (e) {
      debugPrint('CloudinaryService: Initialization failed: $e');
      rethrow;
    }
  }

  /// Upload image from XFile and return the secure URL
  static Future<String> uploadImage({
    required XFile imageFile,
    String? folder,
    String? publicId,
  }) async {
    try {
      await initialize();

      debugPrint('☁️ CloudinaryService: Starting image upload');
      debugPrint('📁 Local image path: ${imageFile.path}');
      debugPrint('🔧 Upload settings: folder=lost-items, cloud=$_cloudName');
      
      // Create upload resource using file path
      final response = await _cloudinary.upload(
        file: imageFile.path,
        folder: folder ?? 'lost-items',
        publicId: publicId,
        resourceType: CloudinaryResourceType.image,
      );

      if (response.isSuccessful && response.secureUrl != null) {
        debugPrint('🎉 CloudinaryService: Upload successful!');
        debugPrint('🌍 CLOUDINARY SECURE URL: ${response.secureUrl}');
        debugPrint('📊 Response data: $response');
        return response.secureUrl!;
      } else {
        debugPrint('❌ CloudinaryService: Upload failed');
        debugPrint('🔍 Error details: ${response.error}');
        debugPrint('📊 Full response: $response');
        throw Exception('Upload failed: ${response.error}');
      }
    } catch (e) {
      debugPrint('❌ CloudinaryService: Upload error: $e');
      rethrow;
    }
  }

  /// Upload image from File path and return the secure URL
  static Future<String> uploadImageFromPath({
    required String filePath,
    String? folder,
    String? publicId,
  }) async {
    try {
      await initialize();

      debugPrint('CloudinaryService: Starting image upload from path');
      debugPrint('File path: $filePath');
      
      // Create upload resource using file path directly
      final response = await _cloudinary.upload(
        file: filePath,
        folder: folder ?? 'lost-items',
        publicId: publicId,
        resourceType: CloudinaryResourceType.image,
      );

      if (response.isSuccessful && response.secureUrl != null) {
        debugPrint('CloudinaryService: Upload successful');
        debugPrint('Secure URL: ${response.secureUrl}');
        return response.secureUrl!;
      } else {
        throw Exception('Upload failed: ${response.error}');
      }
    } catch (e) {
      debugPrint('CloudinaryService: Upload error: $e');
      rethrow;
    }
  }

  /// Upload image with progress callback (enhanced with file_upload_widget.dart standards)
  static Future<String> uploadImageWithProgress({
    required XFile imageFile,
    String? folder,
    String? publicId,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      await initialize();

      debugPrint('☁️ CloudinaryService: Starting image upload with progress');
      debugPrint('📁 Upload folder: ${folder ?? 'lost-items'}');
      debugPrint('🏷️ Public ID: ${publicId ?? 'auto-generated'}');
      debugPrint('📱 Image file path: ${imageFile.path}');
      
      // Get file size and validate (following file_upload_widget.dart standards)
      final file = File(imageFile.path);
      final fileSize = await file.length();
      final formattedSize = formatFileSize(fileSize);
      
      debugPrint('📏 File size: $fileSize bytes ($formattedSize)');
      
      // Validate file size before upload (following file_upload_widget.dart standards)
      if (!isValidImageSize(fileSize)) {
        final maxSizeFormatted = formatFileSize(maxImageSizeBytes);
        throw Exception('Image size exceeds $maxSizeFormatted limit. Current size: $formattedSize');
      }
      
      // Simulate progress start
      if (onProgress != null) {
        debugPrint('📊 Calling progress callback: 0/$fileSize');
        onProgress(0, fileSize);
      }
      
      debugPrint('🚀 Calling Cloudinary upload API...');
      
      try {
        final response = await _cloudinary.upload(
          file: imageFile.path,
          folder: folder ?? 'lost-items',
          publicId: publicId,
          resourceType: CloudinaryResourceType.image,
        );
        
        debugPrint('📨 Cloudinary API response received');

        // Simulate progress complete
        if (onProgress != null) {
          debugPrint('📊 Calling progress callback: $fileSize/$fileSize (100%)');
          onProgress(fileSize, fileSize);
        }

        // Enhanced response validation (following file_upload_widget.dart standards)
        if (response.isSuccessful && response.secureUrl != null) {
          debugPrint('🎉 CloudinaryService: Upload successful!');
          debugPrint('📄 Image uploaded successfully: ${imageFile.name} | Size: $formattedSize | URL: ${response.secureUrl}');
          debugPrint('🌍 CLOUDINARY SECURE URL: ${response.secureUrl}');
          debugPrint('📊 Upload response data: $response');
          return response.secureUrl!;
        } else {
          debugPrint('❌ CloudinaryService: Upload failed');
          debugPrint('🔍 Error details: ${response.error}');
          debugPrint('📊 Full response: $response');
          throw Exception('Cloudinary upload failed: ${response.error}');
        }
      } catch (uploadError) {
        debugPrint('💥 Detailed error during image upload: $uploadError');
        throw Exception('Upload failed: $uploadError');
      }
    } catch (e) {
      debugPrint('❌ CloudinaryService: Upload error: $e');
      rethrow;
    }
  }

  /// Generate a basic transformation URL for existing image
  static String getTransformedImageUrl({
    required String publicId,
    int? width,
    int? height,
    String quality = 'auto:good',
    String format = 'auto',
  }) {
    try {
      // For basic usage without complex transformations
      // Build URL manually following Cloudinary format
      var transformations = <String>[];
      
      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
      transformations.add('q_$quality');
      transformations.add('f_$format');
      transformations.add('c_limit');
      
      final transformStr = transformations.join(',');
      return 'https://res.cloudinary.com/$_cloudName/image/upload/$transformStr/$publicId';
    } catch (e) {
      debugPrint('CloudinaryService: Transform URL error: $e');
      return '';
    }
  }

  /// Delete image from Cloudinary
  static Future<bool> deleteImage({
    required String publicId,
    CloudinaryResourceType resourceType = CloudinaryResourceType.image,
  }) async {
    try {
      await initialize();

      debugPrint('CloudinaryService: Deleting image with publicId: $publicId');
      
      final response = await _cloudinary.destroy(
        publicId,
        resourceType: resourceType,
      );

      if (response.isSuccessful) {
        debugPrint('CloudinaryService: Delete successful');
        return true;
      } else {
        debugPrint('CloudinaryService: Delete failed: ${response.error}');
        return false;
      }
    } catch (e) {
      debugPrint('CloudinaryService: Delete error: $e');
      return false;
    }
  }

  /// Extract public ID from Cloudinary URL
  static String? extractPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find the segment after 'upload'
      int uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex < pathSegments.length - 2) {
        // Skip version if present (starts with 'v')
        int startIndex = uploadIndex + 1;
        if (pathSegments[startIndex].startsWith('v')) {
          startIndex++;
        }
        
        // Join remaining segments and remove file extension
        final publicIdWithExtension = pathSegments.skip(startIndex).join('/');
        final lastDotIndex = publicIdWithExtension.lastIndexOf('.');
        
        if (lastDotIndex != -1) {
          return publicIdWithExtension.substring(0, lastDotIndex);
        }
        
        return publicIdWithExtension;
      }
      
      return null;
    } catch (e) {
      debugPrint('CloudinaryService: Error extracting public ID: $e');
      return null;
    }
  }

  /// Check if service is initialized
  static bool get isInitialized => _isInitialized;

  /// Get Cloudinary instance (for advanced usage)
  static Cloudinary get instance {
    if (!_isInitialized) {
      throw StateError('CloudinaryService not initialized. Call initialize() first.');
    }
    return _cloudinary;
  }
}