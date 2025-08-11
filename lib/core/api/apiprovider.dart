import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'apiendpoints.dart';
import 'dio_client.dart';

class ApiProvider {
  final DioClient _dioClient;
  late final Dio _dio;

  ApiProvider({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient() {
    _dio = _dioClient.dio;
  }

  // Create a new lost item (POST)
  Future<Response> createLostItem({
    required Map<String, dynamic> itemData,
  }) async {
    try {
      debugPrint('Creating lost item with data: $itemData');
      
      final response = await _dio.post(
        ApiEndpoints.createLostItem,
        data: itemData,
      );
      
      debugPrint('Create lost item response: ${response.statusCode}');
      return response;
      
    } on DioException catch (e) {
      debugPrint('Create lost item error: ${e.message}');
      debugPrint('Error response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error creating lost item: $e');
      rethrow;
    }
  }

  // Get lost items with optional query parameters (GET)
  Future<Response> getLostItems({
    int? limit = 20,
    int? skip = 0,
    String? category,
    String? search,
    double? minLat,
    double? maxLat,
    double? minLng,
    double? maxLng,
  }) async {
    try {
      final queryString = ApiEndpoints.buildLostItemsQuery(
        limit: limit,
        skip: skip,
        category: category,
        search: search,
        minLat: minLat,
        maxLat: maxLat,
        minLng: minLng,
        maxLng: maxLng,
      );
      
      final url = '${ApiEndpoints.getLostItems}$queryString';
      debugPrint('Getting lost items from: $url');
      
      final response = await _dio.get(url);
      
      debugPrint('Get lost items response: ${response.statusCode}');
      return response;
      
    } on DioException catch (e) {
      debugPrint('Get lost items error: ${e.message}');
      debugPrint('Error response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error getting lost items: $e');
      rethrow;
    }
  }

  // Get specific lost item by ID (GET)
  Future<Response> getLostItemById(String itemId) async {
    try {
      final url = ApiEndpoints.getLostItemById(itemId);
      debugPrint('Getting lost item by ID from: $url');
      
      final response = await _dio.get(url);
      
      debugPrint('Get lost item by ID response: ${response.statusCode}');
      return response;
      
    } on DioException catch (e) {
      debugPrint('Get lost item by ID error: ${e.message}');
      debugPrint('Error response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error getting lost item by ID: $e');
      rethrow;
    }
  }

  // Get nearby items (GET)
  Future<Response> getNearbyItems({
    required double latitude,
    required double longitude,
    double? radius = 10,
  }) async {
    try {
      final queryString = ApiEndpoints.buildNearbyItemsQuery(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      
      final url = '${ApiEndpoints.getNearbyItems}$queryString';
      debugPrint('Getting nearby items from: $url');
      
      final response = await _dio.get(url);
      
      debugPrint('Get nearby items response: ${response.statusCode}');
      return response;
      
    } on DioException catch (e) {
      debugPrint('Get nearby items error: ${e.message}');
      debugPrint('Error response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error getting nearby items: $e');
      rethrow;
    }
  }

  // Upload image for lost item (if needed - POST with multipart)
  Future<Response> uploadImage({
    required String filePath,
    String? itemId,
  }) async {
    try {
      debugPrint('Uploading image: $filePath');
      
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        if (itemId != null) 'item_id': itemId,
      });

      final response = await _dio.post(
        '${ApiEndpoints.lostItems}/upload/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      debugPrint('Upload image response: ${response.statusCode}');
      return response;
      
    } on DioException catch (e) {
      debugPrint('Upload image error: ${e.message}');
      debugPrint('Error response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error uploading image: $e');
      rethrow;
    }
  }

  // Generic GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      debugPrint('Making GET request to: $endpoint');
      
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      
      debugPrint('GET response: ${response.statusCode}');
      return response;
      
    } on DioException catch (e) {
      debugPrint('GET error: ${e.message}');
      rethrow;
    }
  }

  // Generic POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      debugPrint('Making POST request to: $endpoint');
      
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      debugPrint('POST response: ${response.statusCode}');
      return response;
      
    } on DioException catch (e) {
      debugPrint('POST error: ${e.message}');
      rethrow;
    }
  }

  // Generic PUT request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      debugPrint('Making PUT request to: $endpoint');
      
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      debugPrint('PUT response: ${response.statusCode}');
      return response;
      
    } on DioException catch (e) {
      debugPrint('PUT error: ${e.message}');
      rethrow;
    }
  }

  // Generic DELETE request
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      debugPrint('Making DELETE request to: $endpoint');
      
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      
      debugPrint('DELETE response: ${response.statusCode}');
      return response;
      
    } on DioException catch (e) {
      debugPrint('DELETE error: ${e.message}');
      rethrow;
    }
  }
}