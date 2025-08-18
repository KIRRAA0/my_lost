import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/api/apiprovider.dart';
import '../../../data/Models/lost_item_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ApiProvider _apiProvider;
  
  HomeCubit({ApiProvider? apiProvider}) 
      : _apiProvider = apiProvider ?? ApiProvider(),
        super(HomeInitial());

  static const List<String> categories = [
    'All',
    'Electronics',
    'Clothing',
    'Accessories',
    'Documents',
    'Keys',
    'Bags',
    'Jewelry',
    'Sports',
    'Books',
    'Other'
  ];

  void loadInitialData({Function(LostItem)? onMarkerTap}) async {
    emit(HomeLoading());
    
    try {
      debugPrint('HomeCubit: Loading lost items from API...');
      
      // Fetch items from API
      final response = await _apiProvider.getLostItems(
        limit: 100, // Get a reasonable number of items
        skip: 0,
      );
      
      debugPrint('HomeCubit: API response received with status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Handle both wrapped and direct array responses
        final List<dynamic> itemsJson = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
        debugPrint('HomeCubit: Parsing ${itemsJson.length} items from API response');
        
        // Convert API response to LostItem objects
        final items = itemsJson.map((json) => LostItem.fromApiResponse(json)).toList();
        final markers = _createMarkers(items, 'All', onMarkerTap: onMarkerTap);
        
        debugPrint('HomeCubit: Successfully loaded ${items.length} items');
        
        emit(HomeLoaded(
          allItems: items,
          filteredItems: items,
          markers: markers,
          selectedCategory: 'All',
          currentZoom: 12.0,
          isSearchExpanded: false,
          showMapControls: true,
        ));

        // Get current location after initial load
        _getCurrentLocation();
      } else {
        debugPrint('HomeCubit: API error - Status: ${response.statusCode}');
        throw Exception('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('HomeCubit: Error loading items: $e');
      emit(HomeError(message: 'Failed to load lost items. Please check your internet connection and try again.'));
    }
  }

  void filterByCategory(String category, {Function(LostItem)? onMarkerTap}) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filteredItems = category == 'All'
          ? currentState.allItems
          : currentState.allItems.where((item) => item.category == category).toList();
      
      final markers = _createMarkers(currentState.allItems, category, onMarkerTap: onMarkerTap);
      
      emit(currentState.copyWith(
        filteredItems: filteredItems,
        markers: markers,
        selectedCategory: category,
      ));
    }
  }

  void toggleSearch() {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(
        isSearchExpanded: !currentState.isSearchExpanded,
      ));
    }
  }

  void updateZoom(double zoom) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(currentZoom: zoom));
    }
  }

  void searchItems(String query) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      
      if (query.isEmpty) {
        final filteredItems = currentState.selectedCategory == 'All'
            ? currentState.allItems
            : currentState.allItems.where((item) => item.category == currentState.selectedCategory).toList();
        
        emit(currentState.copyWith(filteredItems: filteredItems));
      } else {
        final searchResults = currentState.allItems.where((item) {
          final matchesQuery = item.title.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase()) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
          
          final matchesCategory = currentState.selectedCategory == 'All' || 
              item.category == currentState.selectedCategory;
          
          return matchesQuery && matchesCategory;
        }).toList();
        
        emit(currentState.copyWith(filteredItems: searchResults));
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        emit(LocationPermissionPermanentlyDenied());
        return;
      }

      if (permission == LocationPermission.denied) {
        emit(LocationPermissionDenied());
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(currentState.copyWith(currentPosition: position));
      }
    } catch (e) {
      // Handle location error silently for now
    }
  }

  /// Load nearby items based on current location
  Future<void> loadNearbyItems({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    Function(LostItem)? onMarkerTap,
  }) async {
    try {
      debugPrint('HomeCubit: Loading nearby items at lat: $latitude, lng: $longitude, radius: $radius km');
      
      final response = await _apiProvider.getNearbyItems(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      if (response.statusCode == 200) {
        // Handle both wrapped and direct array responses
        final List<dynamic> itemsJson = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
        debugPrint('HomeCubit: Found ${itemsJson.length} nearby items');
        
        final nearbyItems = itemsJson.map((json) => LostItem.fromApiResponse(json)).toList();
        
        if (state is HomeLoaded) {
          final currentState = state as HomeLoaded;
          
          // Combine all items with nearby items (avoid duplicates)
          final allItems = <LostItem>[...currentState.allItems];
          for (final nearbyItem in nearbyItems) {
            if (!allItems.any((item) => item.id == nearbyItem.id)) {
              allItems.add(nearbyItem);
            }
          }
          
          final markers = _createMarkers(allItems, currentState.selectedCategory, onMarkerTap: onMarkerTap);
          
          emit(currentState.copyWith(
            allItems: allItems,
            filteredItems: currentState.selectedCategory == 'All' 
                ? allItems 
                : allItems.where((item) => item.category == currentState.selectedCategory).toList(),
            markers: markers,
          ));
        }
      }
    } catch (e) {
      debugPrint('HomeCubit: Error loading nearby items: $e');
      // Don't emit error for nearby items - just log it
    }
  }

  /// Get specific lost item by ID
  Future<LostItem?> getLostItemById(String itemId) async {
    try {
      debugPrint('HomeCubit: Fetching item details for ID: $itemId');
      
      final response = await _apiProvider.getLostItemById(itemId);
      
      if (response.statusCode == 200) {
        // Handle both wrapped and direct object responses
        final itemJson = response.data is Map<String, dynamic>
            ? response.data
            : response.data['data'] ?? {};
        return LostItem.fromApiResponse(itemJson);
      } else {
        debugPrint('HomeCubit: Failed to fetch item details - Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('HomeCubit: Error fetching item details: $e');
      return null;
    }
  }

  /// Refresh items data
  Future<void> refreshItems({Function(LostItem)? onMarkerTap}) async {
    loadInitialData(onMarkerTap: onMarkerTap);
  }

  Set<Marker> _createMarkers(List<LostItem> items, String selectedCategory, {Function(LostItem)? onMarkerTap}) {
    final filteredItems = selectedCategory == 'All'
        ? items
        : items.where((item) => item.category == selectedCategory).toList();

    return filteredItems.map((item) {
      return Marker(
        markerId: MarkerId(item.id),
        position: LatLng(item.latitude, item.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerColor(item.category)),
        infoWindow: InfoWindow(
          title: item.title,
          snippet: item.category,
        ),
        onTap: () {
          if (onMarkerTap != null) {
            onMarkerTap(item);
          }
        },
      );
    }).toSet();
  }

  double _getMarkerColor(String category) {
    switch (category) {
      case 'Electronics':
        return BitmapDescriptor.hueBlue;
      case 'Clothing':
        return BitmapDescriptor.hueGreen;
      case 'Accessories':
        return BitmapDescriptor.hueMagenta;
      case 'Documents':
        return BitmapDescriptor.hueOrange;
      case 'Keys':
        return BitmapDescriptor.hueYellow;
      case 'Bags':
        return BitmapDescriptor.hueCyan;
      case 'Jewelry':
        return BitmapDescriptor.hueViolet;
      case 'Sports':
        return BitmapDescriptor.hueAzure;
      case 'Books':
        return BitmapDescriptor.hueRose;
      default:
        return BitmapDescriptor.hueRed;
    }
  }


}
