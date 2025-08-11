import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/Utils/app_colors.dart';
import '../../../../logic/cubits/report/report_item_state.dart';

mixin StateManagementMixin<T extends StatefulWidget> on State<T> {
  void handleReportItemStateChanges(ReportItemState state) {
    debugPrint('🔄 ReportItemScreen: State changed to ${state.runtimeType}');
    
    switch (state) {
      case ImageUploading _:
        _handleImageUploading(state);
        break;
      case ImageUploadSuccess _:
        _handleImageUploadSuccess(state);
        break;
      case ReportItemSuccess _:
        _handleReportItemSuccess(state);
        break;
      case ReportItemError _:
        _handleReportItemError(state);
        break;
      case ImageUploadError _:
        _handleImageUploadError(state);
        break;
      case ReportItemValidationError _:
        _handleValidationError(state);
        break;
      default:
        break;
    }
  }

  void _handleImageUploading(ImageUploading state) {
    debugPrint('📤 UI: Image uploading - ${state.progress}% - ${state.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
                value: state.progress / 100,
              ),
            ),
            const SizedBox(width: 12),
            Text(state.message),
          ],
        ),
        backgroundColor: AppColors.lightPrimaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(minutes: 2),
      ),
    );
  }

  void _handleImageUploadSuccess(ImageUploadSuccess state) {
    debugPrint('🖼️ UI: IMAGE UPLOADED SUCCESSFULLY!');
    debugPrint('📍 UI: Image URL received: ${state.imageUrl}');
    
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_upload, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(child: Text('Image uploaded to Cloudinary successfully!')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleReportItemSuccess(ReportItemSuccess state) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(state.message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && context.mounted) {
        context.pop();
      }
    });
  }

  void _handleReportItemError(ReportItemError state) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    
    debugPrint('❌ UI: Error state received - ${state.runtimeType}: ${state.message}');
        
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(state.message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _handleImageUploadError(ImageUploadError state) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    
    debugPrint('❌ UI: Error state received - ${state.runtimeType}: ${state.message}');
        
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(state.message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _handleValidationError(ReportItemValidationError state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please fix the following errors:'),
            const SizedBox(height: 4),
            ...state.errors.values.map((error) => Text('• $error')),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  bool isLoadingState(ReportItemState state) {
    return state is ReportItemLoading || state is ImageUploading;
  }
}