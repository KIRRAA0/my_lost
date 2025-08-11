import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/Utils/app_colors.dart';
import '../../../logic/cubits/report/report_item_cubit.dart';
import '../../../logic/cubits/report/report_item_state.dart';
import 'constants/report_item_constants.dart';
import 'mixins/form_data_manager_mixin.dart';
import 'mixins/location_management_mixin.dart';
import 'mixins/report_screen_animation_mixin.dart';
import 'mixins/state_management_mixin.dart';
import '../../Widgets/home/category_selection_widget.dart';
import '../../Widgets/home/finder_information_form_widget.dart';
import '../../Widgets/home/image_upload_widget.dart';
import '../../Widgets/home/item_details_form_widget.dart';
import '../../Widgets/home/location_section_widget.dart';
import '../../Widgets/home/submit_button_widget.dart';

class ReportItemScreen extends StatefulWidget {
  const ReportItemScreen({super.key});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen>
    with 
      TickerProviderStateMixin,
      ReportScreenAnimationMixin,
      LocationManagementMixin,
      FormDataManagerMixin,
      StateManagementMixin {

  String? uploadedImageUrl; // Store the Cloudinary URL

  @override
  void initState() {
    super.initState();
    initializeAnimations();
    getCurrentLocation();
  }

  Future<void> submitReport() async {
    debugPrint('🚀 SUBMIT REPORT: Form submission started');
    debugPrint('📱 SUBMIT REPORT: Uploaded image URL: ${uploadedImageUrl ?? "NULL"}');
    
    if (!validateForm()) {
      debugPrint('❌ SUBMIT REPORT: Form validation failed');
      return;
    }
    debugPrint('✅ SUBMIT REPORT: Form validation passed');

    if (!validateLocationData()) {
      debugPrint('❌ SUBMIT REPORT: Location validation failed');
      return;
    }
    debugPrint('✅ SUBMIT REPORT: Location validation passed');

    double latitude = currentPosition?.latitude ?? 0.0;
    double longitude = currentPosition?.longitude ?? 0.0;
    String address = getSelectedAddress();

    debugPrint('📍 SUBMIT REPORT: Location - Lat: $latitude, Lng: $longitude');
    debugPrint('📍 SUBMIT REPORT: Address: $address');
    debugPrint('🚀 SUBMIT REPORT: About to submit with image URL: ${uploadedImageUrl ?? "NULL"}');

    // Create a simple request object to send to API
    final request = {
      'itemName': itemNameController.text.trim(),
      'description': itemDescriptionController.text.trim(),
      'category': selectedCategory,
      'finderName': finderNameController.text.trim(),
      'finderEmail': finderEmailController.text.trim(),
      'finderPhone': finderPhoneController.text.trim().isEmpty 
          ? null 
          : finderPhoneController.text.trim(),
      'additionalNotes': additionalInfoController.text.trim().isEmpty 
          ? null 
          : additionalInfoController.text.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'imageUrl': uploadedImageUrl ?? 'https://via.placeholder.com/400x300?text=No+Image',
    };

    debugPrint('📋 SUBMIT REPORT: Final request data: $request');

    // Here you would normally call your API directly
    // For now, just show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(child: Text('Report submitted successfully!')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate back after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    disposeAnimations();
    disposeFormControllers();
    disposeLocationControllers();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Report Found Item',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildFormContent(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocationSectionWidget(
              currentAddress: currentAddress,
              isLoadingLocation: isLoadingLocation,
              showManualLocation: showManualLocation,
              manualLocationController: manualLocationController,
              onRefreshLocation: getCurrentLocation,
              onToggleManualLocation: toggleManualLocation,
              isDarkMode: isDarkMode,
            ),

            SizedBox(height: ReportItemConstants.cardSpacing),

            ImageUploadWidget(
              isDarkMode: isDarkMode,
              onImageUploaded: (imageUrl) {
                setState(() {
                  uploadedImageUrl = imageUrl;
                });
                debugPrint('📸 IMAGE UPLOADED: $imageUrl');
              },
            ),

            SizedBox(height: ReportItemConstants.cardSpacing),

            CategorySelectionWidget(
              selectedCategory: selectedCategory,
              categories: ReportItemConstants.categories,
              categoryIcons: ReportItemConstants.categoryIcons,
              onCategoryChanged: updateSelectedCategory,
              isDarkMode: isDarkMode,
            ),

            SizedBox(height: ReportItemConstants.cardSpacing),

            ItemDetailsFormWidget(
              itemNameController: itemNameController,
              itemDescriptionController: itemDescriptionController,
              additionalInfoController: additionalInfoController,
            ),

            SizedBox(height: ReportItemConstants.sectionSpacing),

            FinderInformationFormWidget(
              finderNameController: finderNameController,
              finderEmailController: finderEmailController,
              finderPhoneController: finderPhoneController,
            ),

            SizedBox(height: ReportItemConstants.sectionSpacing),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => ReportItemCubit(),
      child: BlocListener<ReportItemCubit, ReportItemState>(
        listener: (context, state) => handleReportItemStateChanges(state),
        child: BlocBuilder<ReportItemCubit, ReportItemState>(
          builder: (context, state) {
            final isLoading = isLoadingState(state);
            
            return Scaffold(
              appBar: _buildAppBar(),
              body: buildAnimatedContent(
                child: Column(
                  children: [
                    Expanded(child: _buildFormContent(isDarkMode)),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: SubmitButtonWidget(
                        isLoading: isLoading,
                        onSubmit: submitReport,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}