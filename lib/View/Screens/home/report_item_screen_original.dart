import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/Utils/app_colors.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../logic/cubits/report/report_item_cubit.dart';
import '../../../logic/cubits/report/report_item_state.dart';
import '../../Widgets/home/category_selection_widget.dart';
import '../../Widgets/home/finder_information_form_widget.dart';
import '../../Widgets/home/image_picker_section_widget.dart';
import '../../Widgets/home/item_details_form_widget.dart';
import '../../Widgets/home/location_section_widget.dart';
import '../../Widgets/home/submit_button_widget.dart';

class ReportItemScreen extends StatefulWidget {
  const ReportItemScreen({super.key});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _manualLocationController = TextEditingController();
  final _finderNameController = TextEditingController();
  final _finderEmailController = TextEditingController();
  final _finderPhoneController = TextEditingController();
  final _geocodingService = GeocodingService();

  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String _currentAddress = 'Detecting location...';
  Position? _currentPosition;
  XFile? _selectedImage;
  String _selectedCategory = 'Electronics';
  bool _isLoadingLocation = true;
  bool _showManualLocation = false;

  final List<String> _categories = [
    'Electronics',
    'Personal Items',
    'Documents',
    'Jewelry',
    'Clothing',
    'Bags',
    'Keys',
    'Other'
  ];

  final Map<String, IconData> _categoryIcons = {
    'Electronics': Iconsax.mobile,
    'Personal Items': Iconsax.personalcard,
    'Documents': Iconsax.document,
    'Jewelry': Iconsax.crown,
    'Clothing': Iconsax.crown,
    'Bags': Iconsax.bag,
    'Keys': Iconsax.key,
    'Other': Iconsax.category_2
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getCurrentLocation();
    _initializeImageService();
  }

  Future<void> _initializeImageService() async {
    try {
      await ImagePickerService.initialize();
      debugPrint('Image picker service initialized successfully');
    } catch (e) {
      debugPrint('Image picker service initialization failed: $e');
    }
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // Use Google Maps Geocoding API via our service
      String address = await _geocodingService.getAddressFromCoordinates(latitude, longitude);
      return address;
    } catch (e) {
      // Log geocoding error for debugging
      debugPrint('Geocoding error: $e');
      // Return coordinates as fallback
      return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoadingLocation = true);

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location services are disabled. Please enable location services in your device settings.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = 'Location permission denied. You can manually enter your location.';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = 'Location permission permanently denied. Please enable in settings or enter location manually.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Convert coordinates to address using improved helper method
      String address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      setState(() {
        _currentAddress = address;
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _currentAddress = 'Unable to get location. You can enter location manually. Error: ${e.toString()}';
        _isLoadingLocation = false;
      });
      
      // Show a snackbar with more helpful information
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Location detection failed. You can still report the item by entering location details manually.'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _pickImage({ImageSource source = ImageSource.camera}) async {
    // Check service health first
    final isHealthy = await ImagePickerService.isServiceHealthy();
    if (!isHealthy) {
      debugPrint('Image picker service not healthy, attempting reset');
      try {
        await ImagePickerService.reset();
      } catch (e) {
        debugPrint('Service reset failed: $e');
      }
    }

    // Show loading indicator
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

    try {
      debugPrint('ReportScreen: Starting image picker for $source');
      
      // Use the robust image picker service
      final XFile? image = await ImagePickerService.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      // Dismiss loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      }

      if (image != null) {
        setState(() => _selectedImage = image);
        
        // Show success message with file size info
        final int fileSize = await ImagePickerService.getFileSize(image);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Image selected (${ImagePickerService.formatFileSize(fileSize)})'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // User cancelled or no image selected
        debugPrint('ReportScreen: User cancelled image selection or picker failed silently');
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
    } catch (e) {
      debugPrint('ReportScreen: Image picker error: $e');
      
      // Dismiss loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      }
      
      // Show enhanced error dialog with multiple options
      if (mounted) {
        _showImagePickerErrorDialog(source, e.toString());
      }
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
                _pickImage(
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
              
              // Show resetting message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resetting camera service...'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
              
              // Reset service and retry
              try {
                await ImagePickerService.reset();
                await Future.delayed(const Duration(milliseconds: 500));
                if (mounted) {
                  _pickImage(source: source);
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceBottomSheet(
        onCameraSelected: () => _pickImage(source: ImageSource.camera),
        onGallerySelected: () => _pickImage(source: ImageSource.gallery),
      ),
    );
  }


  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get location coordinates
    double latitude = _currentPosition?.latitude ?? 0.0;
    double longitude = _currentPosition?.longitude ?? 0.0;
    String address = _showManualLocation 
        ? _manualLocationController.text.trim()
        : _currentAddress;

    // If using manual location, we need some coordinates (could be improved with geocoding)
    if (_showManualLocation && (latitude == 0.0 || longitude == 0.0)) {
      // For now, use a default location or handle this case
      // In a real app, you'd geocode the manual address
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please refresh GPS location or use current location for accurate coordinates.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Submit the report using the Bloc
    context.read<ReportItemCubit>().createLostItem(
      itemName: _itemNameController.text.trim(),
      description: _itemDescriptionController.text.trim(),
      category: _selectedCategory,
      finderName: _finderNameController.text.trim(),
      finderEmail: _finderEmailController.text.trim(),
      finderPhone: _finderPhoneController.text.trim().isEmpty 
          ? null 
          : _finderPhoneController.text.trim(),
      additionalNotes: _additionalInfoController.text.trim().isEmpty 
          ? null 
          : _additionalInfoController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      address: address,
      image: _selectedImage,
    );
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _additionalInfoController.dispose();
    _manualLocationController.dispose();
    _finderNameController.dispose();
    _finderEmailController.dispose();
    _finderPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => ReportItemCubit(),
      child: BlocListener<ReportItemCubit, ReportItemState>(
        listener: (context, state) {
          debugPrint('🔄 ReportItemScreen: State changed to ${state.runtimeType}');
          
          if (state is ImageUploading) {
            debugPrint('📤 UI: Image uploading - ${state.progress}% - ${state.message}');
            // Show image upload progress
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
          } else if (state is ImageUploadSuccess) {
            // Print the uploaded image URL for debugging
            debugPrint('🖼️ UI: IMAGE UPLOADED SUCCESSFULLY!');
            debugPrint('📍 UI: Image URL received: ${state.imageUrl}');
            debugPrint('✅ UI: Upload completed, ready for form submission');
            debugPrint('🎉 UI: ImageUploadSuccess state successfully received by UI');
            
            // Show image upload success message
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
          } else if (state is ReportItemSuccess) {
            // Remove any existing snackbars
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            
            // Show success message
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

            // Navigate back after a delay
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && context.mounted) {
                context.pop();
              }
            });
          } else if (state is ReportItemError || state is ImageUploadError) {
            // Remove any existing snackbars
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            
            final message = state is ReportItemError 
                ? state.message 
                : (state as ImageUploadError).message;
                
            debugPrint('❌ UI: Error state received - ${state.runtimeType}: $message');
                
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(message)),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is ReportItemValidationError) {
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
        },
        child: BlocBuilder<ReportItemCubit, ReportItemState>(
          builder: (context, state) {
            final isLoading = state is ReportItemLoading || state is ImageUploading;
            
            return Scaffold(
      appBar: AppBar(
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
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LocationSectionWidget(
                    currentAddress: _currentAddress,
                    isLoadingLocation: _isLoadingLocation,
                    showManualLocation: _showManualLocation,
                    manualLocationController: _manualLocationController,
                    onRefreshLocation: _getCurrentLocation,
                    onToggleManualLocation: () {
                      setState(() {
                        _showManualLocation = !_showManualLocation;
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),

                  const SizedBox(height: 24),

                  ImagePickerSectionWidget(
                    selectedImage: _selectedImage,
                    onShowImageSourceDialog: _showImageSourceDialog,
                    isDarkMode: isDarkMode,
                  ),

                  const SizedBox(height: 24),

                  CategorySelectionWidget(
                    selectedCategory: _selectedCategory,
                    categories: _categories,
                    categoryIcons: _categoryIcons,
                    onCategoryChanged: (String? newValue) {
                      setState(() => _selectedCategory = newValue!);
                    },
                    isDarkMode: isDarkMode,
                  ),

                  const SizedBox(height: 24),

                  ItemDetailsFormWidget(
                    itemNameController: _itemNameController,
                    itemDescriptionController: _itemDescriptionController,
                    additionalInfoController: _additionalInfoController,
                  ),

                  const SizedBox(height: 32),

                  FinderInformationFormWidget(
                    finderNameController: _finderNameController,
                    finderEmailController: _finderEmailController,
                    finderPhoneController: _finderPhoneController,
                  ),

                  const SizedBox(height: 32),

                  SubmitButtonWidget(
                    isLoading: isLoading,
                    onSubmit: _submitReport,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
            );
          },
        ),
      ),
    );
  }
}
