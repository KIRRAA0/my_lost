import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/Utils/app_colors.dart';
import '../../../data/Models/lost_item_model.dart';
import '../../../logic/cubits/home/home_cubit.dart';
import '../../../logic/cubits/home/home_state.dart';
import '../../Widgets/home/category_filter.dart';
import '../../Widgets/home/home_app_bar.dart';
import '../../Widgets/home/item_detail_sheet.dart';
import '../../Widgets/home/map_controls.dart';
import '../../Widgets/home/map_overview_card.dart';
import 'map_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;

  late AnimationController _fabAnimationController;
  late AnimationController _filterAnimationController;
  late AnimationController _statsAnimationController;
  
  late Animation<double> _fabAnimation;
  late Animation<Offset> _filterAnimation;
  late Animation<double> _statsScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Initialize data through cubit with marker tap callback
    context.read<HomeCubit>().loadInitialData(onMarkerTap: _showItemDetails);
  }

  void _initializeAnimations() {
    // Initialize animation controllers
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // Create animations
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );

    _filterAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeOutBack,
    ));

    _statsScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _statsAnimationController, curve: Curves.elasticOut),
    );

    // Start animations with staggered delays
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _filterAnimationController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fabAnimationController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _statsAnimationController.forward();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _goToCurrentLocation() {
    final state = context.read<HomeCubit>().state;
    if (state is HomeLoaded && state.currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(state.currentPosition!.latitude, state.currentPosition!.longitude),
            zoom: 16.0,
          ),
        ),
      );
    } else {
      // Request location again
      context.read<HomeCubit>().loadInitialData(onMarkerTap: _showItemDetails);
    }
  }

  void _showItemDetails(LostItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemDetailSheet(item: item),
    );
  }



  @override
  void dispose() {
    _fabAnimationController.dispose();
    _filterAnimationController.dispose();
    _statsAnimationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: const HomeAppBar(),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.lightPrimaryColor,
              ),
            );
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HomeCubit>().loadInitialData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LocationPermissionDenied) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Location permission denied',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HomeCubit>().loadInitialData(),
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            );
          }

          if (state is LocationPermissionPermanentlyDenied) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_disabled,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Location permission permanently denied.\nPlease enable it in settings.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is! HomeLoaded) {
            return const SizedBox.shrink();
          }

          return Stack(
            children: [
              // Map Widget
              IsolatedMapWidget(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(40.7589, -73.9851), // New York City
                  zoom: 12.0,
                ),
                markers: state.markers,
                onMapCreated: _onMapCreated,
                onCameraMove: (position) {
                  context.read<HomeCubit>().updateZoom(position.zoom);
                },
                myLocationEnabled: true,
                mapStyle: isDarkMode ? _darkMapStyle : null,
              ),

              // Category filter
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: SlideTransition(
                  position: _filterAnimation,
                  child: CategoryFilter(onMarkerTap: _showItemDetails),
                ),
              ),
              
              // Map control panel
              Positioned(
                right: 16,
                top: 80,
                child: MapControls(
                  mapController: _mapController,
                  onLocationTap: _goToCurrentLocation,
                ),
              ),
              
              // Smaller Map Overview Card
              Positioned(
                bottom: 100,
                left: 16,
                right: 16,
                child: ScaleTransition(
                  scale: _statsScaleAnimation,
                  child: const MapOverviewCard(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.lightPrimaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text('Report Lost Item feature coming soon!'),
                    ],
                  ),
                  backgroundColor: AppColors.lightPrimaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            backgroundColor: AppColors.lightPrimaryColor,
            elevation: 0,
            highlightElevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            label: const Text(
              'Report Item',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _darkMapStyle => '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "administrative.country",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#bdbdbd"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#181818"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#1b1b1b"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#2c2c2c"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#8a8a8a"
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#373737"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#3c3c3c"
          }
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#4e4e4e"
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#3d3d3d"
          }
        ]
      }
    ]
  ''';
}