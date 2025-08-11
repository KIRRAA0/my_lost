import 'package:equatable/equatable.dart';

class FinderInfo extends Equatable {
  final String name;
  final String email;
  final String? phone;

  const FinderInfo({
    required this.name,
    required this.email,
    this.phone,
  });

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
    };
  }

  // Create from JSON response
  factory FinderInfo.fromJson(Map<String, dynamic> json) {
    return FinderInfo(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
    );
  }

  // Create copy with updated fields
  FinderInfo copyWith({
    String? name,
    String? email,
    String? phone,
  }) {
    return FinderInfo(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [name, email, phone];

  @override
  String toString() {
    return 'FinderInfo(name: $name, email: $email, phone: $phone)';
  }
}