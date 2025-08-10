import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/Utils/app_colors.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/services/image_picker_service.dart';
import '../../Widgets/Common/custom_text_field.dart';

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
  final _geocodingService = GeocodingService();

  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String _currentAddress = 'Detecting location...';
  // Position? _currentPosition;
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Iconsax.camera,
                    title: 'Camera',
                    subtitle: 'Take a photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(source: ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Iconsax.gallery,
                    title: 'Gallery',
                    subtitle: 'Choose from gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(source: ImageSource.gallery);
                    },
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

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
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

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        // Show dialog asking if user wants to continue without photo
        final bool? continueWithoutPhoto = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Photo Required'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A photo helps identify the lost item.'),
                SizedBox(height: 8),
                Text('Would you like to:'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Continue without photo'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  _showImageSourceDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Photo'),
              ),
            ],
          ),
        );
        
        if (continueWithoutPhoto != true) {
          return; // User chose to continue without photo or cancelled
        }
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Report submitted successfully!'),
            ],
          ),
          backgroundColor: AppColors.lightPrimaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back after a delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _additionalInfoController.dispose();
    _manualLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                  // Location Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientStart.withValues(alpha: 0.1),
                          AppColors.gradientEnd.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.lightPrimaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.lightPrimaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Iconsax.location,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Current Location',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (_isLoadingLocation)
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.lightPrimaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('Detecting location...'),
                                      ],
                                    )
                                  else
                                    Text(
                                      _currentAddress,
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey[300]
                                            : Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Iconsax.refresh),
                                  onPressed: _getCurrentLocation,
                                  color: AppColors.lightPrimaryColor,
                                  tooltip: 'Refresh location',
                                ),
                                IconButton(
                                  icon: Icon(_showManualLocation ? Iconsax.location : Iconsax.edit),
                                  onPressed: () {
                                    setState(() {
                                      _showManualLocation = !_showManualLocation;
                                    });
                                  },
                                  color: AppColors.lightPrimaryColor,
                                  tooltip: _showManualLocation ? 'Use GPS' : 'Enter manually',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Manual Location Input (conditional)
                  if (_showManualLocation) ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _manualLocationController,
                      labelText: 'Manual Location',
                      hintText: 'Enter the location where you found the item...',
                      icon: Iconsax.map,
                      validator: (value) {
                        if (_showManualLocation && (value == null || value.isEmpty)) {
                          return 'Please enter the location';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Photo Section
                  const Text(
                    'Item Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showImageSourceDialog,
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
                        color: isDarkMode
                            ? Colors.grey[850]
                            : Colors.grey[50],
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                children: [
                                  Image.file(
                                    File(_selectedImage!.path),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
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
                            )
                          : Column(
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
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category Selection
                  const Text(
                    'Item Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
                      ),
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: Icon(
                          Iconsax.arrow_down_1,
                          color: AppColors.lightPrimaryColor,
                        ),
                        onChanged: (String? newValue) {
                          setState(() => _selectedCategory = newValue!);
                        },
                        items: _categories.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  _categoryIcons[value],
                                  size: 20,
                                  color: AppColors.lightPrimaryColor,
                                ),
                                const SizedBox(width: 12),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Item Details Form
                  const Text(
                    'Item Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _itemNameController,
                    labelText: 'Item Name',
                    hintText: 'e.g., iPhone 13, Blue Wallet',
                    icon: Iconsax.tag,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the item name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _itemDescriptionController,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the item in detail...',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                                AppColors.lightSecondaryColor.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.note,
                            color: AppColors.lightPrimaryColor,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.lightPrimaryColor,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurfaceColor.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _additionalInfoController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Additional Information (Optional)',
                        hintText: 'Any other details about the item...',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                                AppColors.lightSecondaryColor.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.info_circle,
                            color: AppColors.lightPrimaryColor,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.lightPrimaryColor,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurfaceColor.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: _submitReport,
                      icon: const Icon(
                        Iconsax.send_1,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Submit Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
