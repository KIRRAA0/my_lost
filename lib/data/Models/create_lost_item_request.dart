import 'package:equatable/equatable.dart';
import 'finder_info_model.dart';

class CreateLostItemRequest extends Equatable {
  final double longitude;
  final double latitude;
  final String imageUrl;
  final String description;
  final String? notes;
  final String category;
  final String foundAtAddress;
  final FinderInfo finderInfo;

  const CreateLostItemRequest({
    required this.longitude,
    required this.latitude,
    required this.imageUrl,
    required this.description,
    this.notes,
    required this.category,
    required this.foundAtAddress,
    required this.finderInfo,
  });

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'longitude': longitude,
      'latitude': latitude,
      'image_url': imageUrl,
      'description': description,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'category': category,
      'found_at_address': foundAtAddress,
      'finder_info': finderInfo.toJson(),
    };
  }

  // Create from form data (for frontend usage)
  factory CreateLostItemRequest.fromFormData({
    required double longitude,
    required double latitude,
    required String imageUrl,
    required String itemName,
    required String description,
    String? additionalNotes,
    required String category,
    required String address,
    required String finderName,
    required String finderEmail,
    String? finderPhone,
  }) {
    return CreateLostItemRequest(
      longitude: longitude,
      latitude: latitude,
      imageUrl: imageUrl,
      description: '$itemName - $description',
      notes: additionalNotes,
      category: category.toLowerCase(),
      foundAtAddress: address,
      finderInfo: FinderInfo(
        name: finderName,
        email: finderEmail,
        phone: finderPhone,
      ),
    );
  }

  // Create copy with updated fields
  CreateLostItemRequest copyWith({
    double? longitude,
    double? latitude,
    String? imageUrl,
    String? description,
    String? notes,
    String? category,
    String? foundAtAddress,
    FinderInfo? finderInfo,
  }) {
    return CreateLostItemRequest(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      foundAtAddress: foundAtAddress ?? this.foundAtAddress,
      finderInfo: finderInfo ?? this.finderInfo,
    );
  }

  @override
  List<Object?> get props => [
        longitude,
        latitude,
        imageUrl,
        description,
        notes,
        category,
        foundAtAddress,
        finderInfo,
      ];

  @override
  String toString() {
    return 'CreateLostItemRequest('
        'longitude: $longitude, '
        'latitude: $latitude, '
        'imageUrl: $imageUrl, '
        'description: $description, '
        'notes: $notes, '
        'category: $category, '
        'foundAtAddress: $foundAtAddress, '
        'finderInfo: $finderInfo)';
  }
}