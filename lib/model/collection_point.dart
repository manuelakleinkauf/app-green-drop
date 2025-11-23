import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionPoint {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final String? description;
  final List<String> acceptedItems;

  CollectionPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    this.description,
    required this.acceptedItems,
  });

  factory CollectionPoint.fromMap(Map<String, dynamic> map, String id) {
    return CollectionPoint(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      isActive: map['isActive'] ?? true,
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : (map['createdAt'] as DateTime? ?? DateTime.now()),
      description: map['description'],
      acceptedItems: List<String>.from(map['acceptedItems'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'description': description,
      'acceptedItems': acceptedItems,
    };
  }

  CollectionPoint copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    bool? isActive,
    String? description,
    List<String>? acceptedItems,
  }) {
    return CollectionPoint(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      description: description ?? this.description,
      acceptedItems: acceptedItems ?? this.acceptedItems,
    );
  }
}
