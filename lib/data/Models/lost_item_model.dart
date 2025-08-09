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