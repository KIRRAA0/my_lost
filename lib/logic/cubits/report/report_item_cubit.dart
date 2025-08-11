import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/apiprovider.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../data/Models/create_lost_item_request.dart';
import 'report_item_state.dart';

class ReportItemCubit extends Cubit<ReportItemState> {
  final ApiProvider _apiProvider;

  ReportItemCubit({ApiProvider? apiProvider}) 
      : _apiProvider = apiProvider ?? ApiProvider(),
        super(ReportItemInitial());

  /// Validate form data before submission
  bool _validateFormData({
    required String itemName,
    required String description,
    required String category,
    required String finderName,
    required String finderEmail,
    required double latitude,
    required double longitude,
    required String address,
    XFile? image,
  }) {
    final errors = <String, String>{};

    if (itemName.trim().isEmpty) {
      errors['itemName'] = 'Item name is required';
    }

    if (description.trim().isEmpty) {
      errors['description'] = 'Description is required';
    }

    if (category.trim().isEmpty) {
      errors['category'] = 'Category is required';
    }

    if (finderName.trim().isEmpty) {
      errors['finderName'] = 'Your name is required';
    }

    if (finderEmail.trim().isEmpty) {
      errors['finderEmail'] = 'Email is required';
    } else if (!_isValidEmail(finderEmail)) {
      errors['finderEmail'] = 'Please enter a valid email address';
    }

    if (address.trim().isEmpty) {
      errors['address'] = 'Address is required';
    }

    if (latitude == 0.0 || longitude == 0.0) {
      errors['location'] = 'Location is required';
    }

    if (errors.isNotEmpty) {
      emit(ReportItemValidationError(errors: errors));
      return false;
    }

    return true;
  }

  /// Check if email is valid
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Upload image to Cloudinary
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      emit(const ImageUploading(progress: 0));

      debugPrint('ReportItemCubit: Starting image upload');

      // Initialize Cloudinary service
      await CloudinaryService.initialize();

      // Upload with progress tracking
      final imageUrl = await CloudinaryService.uploadImageWithProgress(
        imageFile: imageFile,
        folder: 'lost-items',
        onProgress: (sent, total) {
          final progress = ((sent / total) * 100).round();
          emit(ImageUploading(
            progress: progress,
            message: 'Uploading image... $progress%',
          ));
        },
      );

      debugPrint('🖼️ ReportItemCubit: IMAGE UPLOADED SUCCESSFULLY!');
      debugPrint('📍 CLOUDINARY IMAGE URL: $imageUrl');
      debugPrint('✅ Image upload completed, returning URL');
      debugPrint('🚀 About to emit ImageUploadSuccess state');
      
      emit(ImageUploadSuccess(imageUrl: imageUrl));
      debugPrint('✅ ImageUploadSuccess state emitted successfully');
      
      return imageUrl;
    } catch (e) {
      debugPrint('❌ ReportItemCubit: Image upload exception caught: $e');
      debugPrint('📍 Exception occurred at: ${DateTime.now()}');
      debugPrint('🔄 About to emit ImageUploadError state');
      emit(ImageUploadError(message: 'Failed to upload image: ${e.toString()}'));
      debugPrint('❌ ImageUploadError state emitted');
      return null;
    }
  }

  /// Create lost item report
  Future<void> createLostItem({
    required String itemName,
    required String description,
    required String category,
    required String finderName,
    required String finderEmail,
    String? finderPhone,
    String? additionalNotes,
    required double latitude,
    required double longitude,
    required String address,
    XFile? image,
  }) async {
    try {
      debugPrint('🎯 CREATE LOST ITEM: Method called with image: ${image != null ? "NOT NULL" : "NULL"}');
      if (image != null) {
        debugPrint('🎯 CREATE LOST ITEM: Image path: ${image.path}');
        debugPrint('🎯 CREATE LOST ITEM: Image name: ${image.name}');
      }
      
      debugPrint('🎯 CREATE LOST ITEM: Starting form validation...');
      // Validate form data first
      if (!_validateFormData(
        itemName: itemName,
        description: description,
        category: category,
        finderName: finderName,
        finderEmail: finderEmail,
        latitude: latitude,
        longitude: longitude,
        address: address,
        image: image,
      )) {
        debugPrint('❌ CREATE LOST ITEM: Form validation failed - returning early');
        return; // Validation failed, error state already emitted
      }
      debugPrint('✅ CREATE LOST ITEM: Form validation passed');

      emit(const ReportItemLoading(loadingMessage: 'Preparing to submit...'));

      String? imageUrl;

      // Upload image if provided
      if (image != null) {
        debugPrint('📤 CREATE LOST ITEM: Starting image upload process...');
        debugPrint('📱 CREATE LOST ITEM: Image file path: ${image.path}');
        debugPrint('📏 CREATE LOST ITEM: Image file size: ${await image.length()} bytes');
        
        try {
          imageUrl = await uploadImage(image);
          if (imageUrl == null) {
            debugPrint('❌ Image upload failed, aborting submission');
            debugPrint('🔍 Upload returned null - check previous error logs');
            // Image upload failed, error already emitted
            return;
          }
          debugPrint('✅ Image upload successful, proceeding with form submission');
          debugPrint('🔗 Final image URL to be sent to API: $imageUrl');
          debugPrint('🎯 Image upload workflow completed successfully');
        } catch (e) {
          debugPrint('💥 Unexpected error during image upload workflow: $e');
          emit(ImageUploadError(message: 'Unexpected error during image upload: ${e.toString()}'));
          return;
        }
      } else {
        debugPrint('📷 CREATE LOST ITEM: No image provided, using placeholder');
        // Use default image URL if no image provided
        imageUrl = 'https://via.placeholder.com/400x300?text=No+Image';
        debugPrint('📷 CREATE LOST ITEM: Placeholder image URL set: $imageUrl');
      }

      emit(const ReportItemLoading(loadingMessage: 'Submitting report...'));

      // Create the request object
      final request = CreateLostItemRequest.fromFormData(
        longitude: longitude,
        latitude: latitude,
        imageUrl: imageUrl,
        itemName: itemName,
        description: description,
        additionalNotes: additionalNotes,
        category: category,
        address: address,
        finderName: finderName,
        finderEmail: finderEmail,
        finderPhone: finderPhone,
      );

      debugPrint('🚀 ReportItemCubit: Sending request to API');
      debugPrint('📋 Full request data: ${request.toJson()}');
      debugPrint('🔗 Image URL in request: ${request.imageUrl}');

      // Submit to API
      final response = await _apiProvider.createLostItem(
        itemData: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('ReportItemCubit: Report submitted successfully');
        final responseData = response.data;
        
        emit(ReportItemSuccess(
          message: 'Lost item report submitted successfully!',
          itemId: responseData['id']?.toString(),
        ));
      } else {
        debugPrint('ReportItemCubit: API error - Status: ${response.statusCode}');
        debugPrint('Response data: ${response.data}');
        
        emit(ReportItemError(
          message: 'Failed to submit report. Please try again.',
          errorCode: response.statusCode.toString(),
        ));
      }
    } catch (e) {
      debugPrint('ReportItemCubit: Unexpected error: $e');
      emit(ReportItemError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Reset state to initial
  void resetState() {
    emit(ReportItemInitial());
  }

  /// Clear any error states
  void clearErrors() {
    if (state is ReportItemError || 
        state is ImageUploadError || 
        state is ReportItemValidationError) {
      emit(ReportItemInitial());
    }
  }
}