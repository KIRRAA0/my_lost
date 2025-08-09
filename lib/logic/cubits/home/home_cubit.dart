import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/Models/lost_item_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

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
      // Load mock data
      final items = _generateMockItems();
      final markers = _createMarkers(items, 'All', onMarkerTap: onMarkerTap);
      
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
    } catch (e) {
      emit(HomeError(message: e.toString()));
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

  List<LostItem> _generateMockItems() {
    return [
      LostItem(
        id: '1',
        title: 'iPhone 14 Pro',
        description: 'Space Black iPhone 14 Pro found near Central Park. Has a cracked screen protector.',
        category: 'Electronics',
        imageUrl: 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=300&h=200&fit=crop',
        latitude: 40.7829,
        longitude: -73.9654,
        address: 'Central Park, New York, NY',
        dateFound: DateTime.now().subtract(const Duration(days: 2)),
        finderName: 'John Smith',
        finderContact: '+1 234 567 8900',
        status: ItemStatus.found,
        tags: ['phone', 'apple', 'black'],
      ),
      LostItem(
        id: '2',
        title: 'Blue Backpack',
        description: 'Nike blue backpack with laptop compartment. Found at coffee shop.',
        category: 'Bags',
        imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300&h=200&fit=crop',
        latitude: 40.7614,
        longitude: -73.9776,
        address: 'Times Square, New York, NY',
        dateFound: DateTime.now().subtract(const Duration(days: 1)),
        finderName: 'Sarah Johnson',
        finderContact: '+1 234 567 8901',
        status: ItemStatus.found,
        tags: ['backpack', 'nike', 'blue'],
      ),
      LostItem(
        id: '3',
        title: 'Car Keys',
        description: 'Toyota car keys with house keys attached. Black keychain.',
        category: 'Keys',
        imageUrl: 'https://images.unsplash.com/photo-1582139329536-e7284fece509?w=300&h=200&fit=crop',
        latitude: 40.7505,
        longitude: -73.9934,
        address: 'Brooklyn Bridge, New York, NY',
        dateFound: DateTime.now().subtract(const Duration(hours: 6)),
        finderName: 'Mike Wilson',
        finderContact: '+1 234 567 8902',
        status: ItemStatus.found,
        tags: ['keys', 'toyota', 'keychain'],
      ),
      LostItem(
        id: '4',
        title: 'Gold Watch',
        description: 'Rolex Submariner gold watch. Found in restaurant.',
        category: 'Jewelry',
        imageUrl: 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=300&h=200&fit=crop',
        latitude: 40.7484,
        longitude: -73.9857,
        address: 'SoHo, New York, NY',
        dateFound: DateTime.now().subtract(const Duration(days: 3)),
        finderName: 'Emma Davis',
        finderContact: '+1 234 567 8903',
        status: ItemStatus.found,
        tags: ['watch', 'rolex', 'gold'],
      ),
      LostItem(
        id: '5',
        title: 'Passport',
        description: 'US Passport in brown leather wallet. Found in taxi.',
        category: 'Documents',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300&h=200&fit=crop',
        latitude: 40.7580,
        longitude: -73.9855,
        address: 'Columbus Circle, New York, NY',
        dateFound: DateTime.now().subtract(const Duration(hours: 12)),
        finderName: 'Alex Rodriguez',
        finderContact: '+1 234 567 8904',
        status: ItemStatus.found,
        tags: ['passport', 'documents', 'wallet'],
      ),
    ];
  }
}
