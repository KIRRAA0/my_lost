import 'package:equatable/equatable.dart';

class LostItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime dateFound;
  final String finderName;
  final String finderContact;
  final ItemStatus status;
  final List<String> tags;

  const LostItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.dateFound,
    required this.finderName,
    required this.finderContact,
    required this.status,
    required this.tags,
  });

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      dateFound: DateTime.parse(json['dateFound'] ?? DateTime.now().toIso8601String()),
      finderName: json['finderName'] ?? '',
      finderContact: json['finderContact'] ?? '',
      status: ItemStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ItemStatus.found,
      ),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // Factory method specifically for API responses
  factory LostItem.fromApiResponse(Map<String, dynamic> json) {
    // Extract title from description if it follows the pattern "Title - Description"
    final fullDescription = json['description'] ?? '';
    final parts = fullDescription.split(' - ');
    final title = parts.length > 1 ? parts[0] : fullDescription.split(' ').take(3).join(' ');
    final description = parts.length > 1 ? parts.sublist(1).join(' - ') : fullDescription;

    // Extract finder info
    final finderInfo = json['finder_info'] ?? {};
    final finderName = finderInfo['name'] ?? 'Anonymous';
    final finderContact = finderInfo['email'] ?? finderInfo['phone'] ?? '';

    // Handle potential date field variations
    final dateField = json['created_at'] ?? json['date_found'] ?? json['dateFound'];
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(dateField);
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return LostItem(
      id: json['_id'] ?? json['id'] ?? '',
      title: title,
      description: description,
      category: json['category']?.toString().toLowerCase() ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? 'https://via.placeholder.com/400x300?text=No+Image',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['found_at_address'] ?? json['address'] ?? '',
      dateFound: parsedDate,
      finderName: finderName,
      finderContact: finderContact,
      status: ItemStatus.found, // Default status for found items
      tags: _generateTagsFromItem(title, description, json['category']?.toString()),
    );
  }

  // Helper method to generate tags from item data
  static List<String> _generateTagsFromItem(String title, String description, String? category) {
    final tags = <String>[];
    
    // Add category as tag
    if (category != null && category.isNotEmpty) {
      tags.add(category.toLowerCase());
    }
    
    // Extract potential tags from title and description
    final combinedText = '$title $description'.toLowerCase();
    final commonBrandKeywords = ['apple', 'samsung', 'nike', 'adidas', 'sony', 'hp', 'dell', 'iphone', 'android'];
    
    for (final keyword in commonBrandKeywords) {
      if (combinedText.contains(keyword)) {
        tags.add(keyword);
      }
    }
    
    // Add color tags if mentioned
    final colors = ['black', 'white', 'red', 'blue', 'green', 'yellow', 'pink', 'purple', 'gray', 'brown'];
    for (final color in colors) {
      if (combinedText.contains(color)) {
        tags.add(color);
      }
    }
    
    return tags;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'dateFound': dateFound.toIso8601String(),
      'finderName': finderName,
      'finderContact': finderContact,
      'status': status.toString().split('.').last,
      'tags': tags,
    };
  }

  LostItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? dateFound,
    String? finderName,
    String? finderContact,
    ItemStatus? status,
    List<String>? tags,
  }) {
    return LostItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      dateFound: dateFound ?? this.dateFound,
      finderName: finderName ?? this.finderName,
      finderContact: finderContact ?? this.finderContact,
      status: status ?? this.status,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        imageUrl,
        latitude,
        longitude,
        address,
        dateFound,
        finderName,
        finderContact,
        status,
        tags,
      ];
}

enum ItemStatus {
  found,
  claimed,
  pending,
}

enum ItemCategory {
  electronics,
  clothing,
  accessories,
  documents,
  keys,
  bags,
  jewelry,
  sports,
  books,
  other,
}

extension ItemCategoryExtension on ItemCategory {
  String get displayName {
    switch (this) {
      case ItemCategory.electronics:
        return 'Electronics';
      case ItemCategory.clothing:
        return 'Clothing';
      case ItemCategory.accessories:
        return 'Accessories';
      case ItemCategory.documents:
        return 'Documents';
      case ItemCategory.keys:
        return 'Keys';
      case ItemCategory.bags:
        return 'Bags';
      case ItemCategory.jewelry:
        return 'Jewelry';
      case ItemCategory.sports:
        return 'Sports';
      case ItemCategory.books:
        return 'Books';
      case ItemCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ItemCategory.electronics:
        return '📱';
      case ItemCategory.clothing:
        return '👕';
      case ItemCategory.accessories:
        return '👜';
      case ItemCategory.documents:
        return '📄';
      case ItemCategory.keys:
        return '🔑';
      case ItemCategory.bags:
        return '🎒';
      case ItemCategory.jewelry:
        return '💍';
      case ItemCategory.sports:
        return '⚽';
      case ItemCategory.books:
        return '📚';
      case ItemCategory.other:
        return '📦';
    }
  }
}