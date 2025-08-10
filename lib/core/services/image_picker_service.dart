import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static ImagePicker? _picker;
  static bool _isInitialized = false;
  
  /// Initialize the image picker service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _picker = ImagePicker();
      
      // Pre-warm the plugin by attempting a very small operation
      if (Platform.isIOS) {
        await Future.delayed(const Duration(milliseconds: 100));
        // Try to access the picker to ensure channel is established
        try {
          await _picker!.retrieveLostData();
        } catch (e) {
          // Ignore errors from retrieveLostData as it's just for initialization
          debugPrint('Initialization check (expected): $e');
        }
      }
      
      _isInitialized = true;
      debugPrint('ImagePickerService initialized successfully');
    } catch (e) {
      debugPrint('ImagePickerService initialization warning: $e');
      // Still mark as initialized to allow fallback methods to work
      _isInitialized = true;
    }
  }
  
  /// Get the picker instance, initializing if needed
  static Future<ImagePicker> _getPickerInstance() async {
    if (!_isInitialized || _picker == null) {
      await initialize();
    }
    return _picker ?? ImagePicker();
  }

  /// Pick image with comprehensive error handling
  static Future<XFile?> pickImage({
    required ImageSource source,
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    int retryCount = 0;
    const int maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        // Ensure picker is initialized
        final picker = await _getPickerInstance();
        
        // Progressive delay based on retry count
        final delayMs = 200 + (retryCount * 300);
        await Future.delayed(Duration(milliseconds: delayMs));
        
        debugPrint('ImagePickerService: Attempt ${retryCount + 1} for $source');
        
        final XFile? image = await picker.pickImage(
          source: source,
          imageQuality: imageQuality,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );

        if (image != null) {
          debugPrint('ImagePickerService: Successfully picked image on attempt ${retryCount + 1}');
          return image;
        }
        
        // User cancelled - don't retry
        debugPrint('ImagePickerService: User cancelled or no image selected');
        return null;
        
      } on PlatformException catch (e) {
        debugPrint('ImagePickerService PlatformException (attempt ${retryCount + 1}): $e');
        
        // Handle specific iOS channel errors
        if (e.code == 'channel-error' || e.message?.contains('Unable to establish connection') == true) {
          if (retryCount < maxRetries - 1) {
            retryCount++;
            debugPrint('ImagePickerService: Retrying due to channel error...');
            continue;
          }
          // Last attempt with iOS workaround
          return await _iosChannelWorkaround(source, imageQuality, maxWidth, maxHeight);
        }
        
        // For other platform exceptions, try fallback immediately
        return await _fallbackImagePicker(source, retryCount);
        
      } on Exception catch (e) {
        debugPrint('ImagePickerService error (attempt ${retryCount + 1}): $e');
        
        if (retryCount < maxRetries - 1) {
          retryCount++;
          continue;
        }
        
        // Final fallback
        return await _fallbackImagePicker(source, retryCount);
      }
    }
    
    debugPrint('ImagePickerService: All retry attempts failed');
    return null;
  }

  /// iOS-specific workaround for channel connection issues
  static Future<XFile?> _iosChannelWorkaround(
    ImageSource source, 
    int imageQuality, 
    double? maxWidth, 
    double? maxHeight
  ) async {
    debugPrint('ImagePickerService: Starting iOS channel workaround');
    
    // Multiple workaround strategies
    final strategies = [
      () async {
        debugPrint('iOS workaround: Strategy 1 - New instance with delay');
        await Future.delayed(const Duration(milliseconds: 1500));
        final newPicker = ImagePicker();
        return await newPicker.pickImage(source: source, imageQuality: imageQuality);
      },
      () async {
        debugPrint('iOS workaround: Strategy 2 - Basic parameters');
        await Future.delayed(const Duration(milliseconds: 800));
        final basicPicker = ImagePicker();
        return await basicPicker.pickImage(source: source);
      },
      () async {
        debugPrint('iOS workaround: Strategy 3 - Reinitialize service');
        _isInitialized = false;
        _picker = null;
        await initialize();
        final reinitPicker = await _getPickerInstance();
        return await reinitPicker.pickImage(source: source, imageQuality: 90);
      }
    ];
    
    for (int i = 0; i < strategies.length; i++) {
      try {
        final result = await strategies[i]();
        if (result != null) {
          debugPrint('iOS workaround: Strategy ${i + 1} succeeded');
          return result;
        }
      } catch (e) {
        debugPrint('iOS workaround: Strategy ${i + 1} failed: $e');
        if (i == strategies.length - 1) {
          debugPrint('iOS workaround: All strategies exhausted');
        }
      }
    }
    
    return null;
  }

  /// Fallback method for when the main picker fails
  static Future<XFile?> _fallbackImagePicker(ImageSource source, int attemptNumber) async {
    try {
      debugPrint('ImagePickerService: Fallback method (attempt $attemptNumber)');
      
      // Create completely fresh picker instance
      final ImagePicker fallbackPicker = ImagePicker();
      
      // Progressive delay based on attempt number
      final delayMs = 500 + (attemptNumber * 200);
      await Future.delayed(Duration(milliseconds: delayMs));
      
      // Use conservative settings for better compatibility
      return await fallbackPicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.rear,
      );
    } catch (e) {
      debugPrint('ImagePickerService: Fallback also failed: $e');
      
      // Ultimate fallback - basic picker with no options
      try {
        debugPrint('ImagePickerService: Ultimate fallback attempt');
        final ultimatePicker = ImagePicker();
        await Future.delayed(const Duration(milliseconds: 1000));
        return await ultimatePicker.pickImage(source: source);
      } catch (e) {
        debugPrint('ImagePickerService: Ultimate fallback failed: $e');
        return null;
      }
    }
  }

  /// Check if camera is available
  static Future<bool> isCameraAvailable() async {
    try {
      await initialize();
      return Platform.isIOS || Platform.isAndroid;
    } catch (e) {
      debugPrint('Camera availability check error: $e');
      return false;
    }
  }

  /// Check if gallery is available
  static Future<bool> isGalleryAvailable() async {
    try {
      await initialize();
      return Platform.isIOS || Platform.isAndroid;
    } catch (e) {
      debugPrint('Gallery availability check error: $e');
      return false;
    }
  }

  /// Check if the service is ready and healthy
  static Future<bool> isServiceHealthy() async {
    try {
      await initialize();
      return _isInitialized && _picker != null;
    } catch (e) {
      debugPrint('Service health check failed: $e');
      return false;
    }
  }

  /// Reset the service (useful for troubleshooting)
  static Future<void> reset() async {
    debugPrint('ImagePickerService: Resetting service');
    _isInitialized = false;
    _picker = null;
    await initialize();
  }

  /// Get file size in bytes
  static Future<int> getFileSize(XFile file) async {
    try {
      final File ioFile = File(file.path);
      return await ioFile.length();
    } catch (e) {
      return 0;
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
