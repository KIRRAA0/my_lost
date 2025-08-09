import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/Models/lost_item_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<LostItem> allItems;
  final List<LostItem> filteredItems;
  final Set<Marker> markers;
  final String selectedCategory;
  final Position? currentPosition;
  final double currentZoom;
  final bool isSearchExpanded;
  final bool showMapControls;

  const HomeLoaded({
    required this.allItems,
    required this.filteredItems,
    required this.markers,
    required this.selectedCategory,
    this.currentPosition,
    required this.currentZoom,
    required this.isSearchExpanded,
    required this.showMapControls,
  });

  @override
  List<Object?> get props => [
        allItems,
        filteredItems,
        markers,
        selectedCategory,
        currentPosition,
        currentZoom,
        isSearchExpanded,
        showMapControls,
      ];

  HomeLoaded copyWith({
    List<LostItem>? allItems,
    List<LostItem>? filteredItems,
    Set<Marker>? markers,
    String? selectedCategory,
    Position? currentPosition,
    double? currentZoom,
    bool? isSearchExpanded,
    bool? showMapControls,
  }) {
    return HomeLoaded(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      markers: markers ?? this.markers,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentPosition: currentPosition ?? this.currentPosition,
      currentZoom: currentZoom ?? this.currentZoom,
      isSearchExpanded: isSearchExpanded ?? this.isSearchExpanded,
      showMapControls: showMapControls ?? this.showMapControls,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LocationPermissionDenied extends HomeState {}

class LocationPermissionPermanentlyDenied extends HomeState {}
