import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/geocoding_service.dart';

mixin LocationManagementMixin<T extends StatefulWidget> on State<T> {
  final GeocodingService _geocodingService = GeocodingService();
  
  String _currentAddress = 'Detecting location...';
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _showManualLocation = false;
  
  final TextEditingController _manualLocationController = TextEditingController();

  String get currentAddress => _currentAddress;
  Position? get currentPosition => _currentPosition;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get showManualLocation => _showManualLocation;
  TextEditingController get manualLocationController => _manualLocationController;

  void toggleManualLocation() {
    setState(() {
      _showManualLocation = !_showManualLocation;
    });
  }

  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      String address = await _geocodingService.getAddressFromCoordinates(latitude, longitude);
      return address;
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      setState(() => _isLoadingLocation = true);

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location services are disabled. Please enable location services in your device settings.';
          _isLoadingLocation = false;
        });
        return;
      }

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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

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

  bool validateLocationData() {
    double latitude = _currentPosition?.latitude ?? 0.0;
    double longitude = _currentPosition?.longitude ?? 0.0;
    
    if (_showManualLocation && (latitude == 0.0 || longitude == 0.0)) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please refresh GPS location or use current location for accurate coordinates.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
    return true;
  }

  String getSelectedAddress() {
    return _showManualLocation 
        ? _manualLocationController.text.trim()
        : _currentAddress;
  }

  void disposeLocationControllers() {
    _manualLocationController.dispose();
  }
}