class ApiEndpoints {
  // Base URL for the API
  static const String baseUrl = 'https://api-mylost.vercel.app';

  // API version
  static const String apiVersion = '/api/v1';

  // Complete base URL with version
  static const String fullBaseUrl = '$baseUrl$apiVersion';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Lost Items Endpoints
  static const String lostItems = '$fullBaseUrl/lost-items';
  
  // Create new lost item (POST)
  static const String createLostItem = '$lostItems/';
  
  // Get lost items with query parameters (GET)
  // Params: limit, skip, category, search, min_lat, max_lat, min_lng, max_lng
  static const String getLostItems = '$lostItems/';
  
  // Get specific lost item by ID (GET)
  static String getLostItemById(String itemId) => '$lostItems/$itemId';
  
  // Get nearby items (GET)
  // Params: latitude, longitude, radius
  static const String getNearbyItems = '$lostItems/nearby/';

  // Helper method to build query parameters for lost items
  static String buildLostItemsQuery({
    int? limit,
    int? skip,
    String? category,
    String? search,
    double? minLat,
    double? maxLat,
    double? minLng,
    double? maxLng,
  }) {
    final params = <String>[];
    
    if (limit != null) params.add('limit=$limit');
    if (skip != null) params.add('skip=$skip');
    if (category != null && category.isNotEmpty) params.add('category=$category');
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (minLat != null) params.add('min_lat=$minLat');
    if (maxLat != null) params.add('max_lat=$maxLat');
    if (minLng != null) params.add('min_lng=$minLng');
    if (maxLng != null) params.add('max_lng=$maxLng');
    
    return params.isEmpty ? '' : '?${params.join('&')}';
  }

  // Helper method to build query parameters for nearby items
  static String buildNearbyItemsQuery({
    required double latitude,
    required double longitude,
    double? radius,
  }) {
    final params = <String>[];
    
    params.add('latitude=$latitude');
    params.add('longitude=$longitude');
    if (radius != null) params.add('radius=$radius');
    
    return '?${params.join('&')}';
  }
}