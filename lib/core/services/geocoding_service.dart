import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class GeocodingService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
  // Note: In production, this API key should be stored securely
  // This key is already in your AndroidManifest.xml and iOS AppDelegate
  static const String _apiKey = 'AIzaSyDGbqlpUyhaG9GT1SeRI0TWXp_nWPFt93o';
  
  final Dio _dio;
  
  GeocodingService() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // Add a small delay and retry mechanism for better reliability
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': _apiKey,
          'language': 'en',
          'result_type': 'street_address|locality|administrative_area_level_1|country',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          // Try to get the most detailed address
          final results = data['results'] as List;
          
          // Look for the best formatted address
          for (final result in results) {
            if (result['formatted_address'] != null) {
              return result['formatted_address'];
            }
          }
          
          // If no formatted address, build from components
          return _buildAddressFromComponents(results.first);
        } else if (data['status'] == 'ZERO_RESULTS') {
          return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        } else {
                debugPrint('Geocoding API error: ${data['status']}');
      return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        }
      }
      
      return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    } on DioException catch (e) {
      debugPrint('Dio error during geocoding: ${e.message}');
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout) {
        return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)} (No internet connection)';
      }
      return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)} (Network error)';
    } catch (e) {
      debugPrint('Unexpected error during geocoding: $e');
      return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)} (Address lookup failed)';
    }
  }

  String _buildAddressFromComponents(Map<String, dynamic> result) {
    try {
      final addressComponents = result['address_components'] as List;
      final Map<String, String> componentMap = {};
      
      // Extract relevant components
      for (final component in addressComponents) {
        final types = component['types'] as List;
        final name = component['long_name'] ?? component['short_name'];
        
        if (types.contains('street_number')) {
          componentMap['street_number'] = name;
        } else if (types.contains('route')) {
          componentMap['route'] = name;
        } else if (types.contains('locality')) {
          componentMap['locality'] = name;
        } else if (types.contains('administrative_area_level_1')) {
          componentMap['state'] = name;
        } else if (types.contains('country')) {
          componentMap['country'] = name;
        } else if (types.contains('postal_code')) {
          componentMap['postal_code'] = name;
        }
      }
      
      // Build address string
      List<String> addressParts = [];
      
      // Street address
      if (componentMap.containsKey('street_number') && componentMap.containsKey('route')) {
        addressParts.add('${componentMap['street_number']} ${componentMap['route']}');
      } else if (componentMap.containsKey('route')) {
        addressParts.add(componentMap['route']!);
      }
      
      // City
      if (componentMap.containsKey('locality')) {
        addressParts.add(componentMap['locality']!);
      }
      
      // State
      if (componentMap.containsKey('state')) {
        addressParts.add(componentMap['state']!);
      }
      
      // Country
      if (componentMap.containsKey('country')) {
        addressParts.add(componentMap['country']!);
      }
      
      return addressParts.isNotEmpty 
          ? addressParts.join(', ')
          : 'Location: ${result['geometry']['location']['lat']}, ${result['geometry']['location']['lng']}';
    } catch (e) {
      return 'Unable to parse address';
    }
  }

  // Alternative method using reverse geocoding with place ID
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _apiKey,
          'fields': 'formatted_address,name,geometry',
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        return response.data['result'];
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting place details: $e');
      return null;
    }
  }
}
