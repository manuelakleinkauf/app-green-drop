import 'package:cloud_firestore/cloud_firestore.dart';

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final bool isAvailable;
  final String? imageUrl;
  final DateTime createdAt;
  final int quantity;
  final List<String> claimedBy;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    this.isAvailable = true,
    this.imageUrl,
    required this.createdAt,
    required this.quantity,
    required this.claimedBy,
  });

  factory Reward.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Reward(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      pointsCost: data['pointsCost'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      quantity: data['quantity'] ?? 0,
      claimedBy: List<String>.from(data['claimedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'pointsCost': pointsCost,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'quantity': quantity,
      'claimedBy': claimedBy,
    };
  }

  bool get hasAvailableQuantity => quantity > claimedBy.length;

  Reward copyWith({
    String? title,
    String? description,
    int? pointsCost,
    bool? isAvailable,
    String? imageUrl,
    int? quantity,
    List<String>? claimedBy,
  }) {
    return Reward(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsCost: pointsCost ?? this.pointsCost,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      quantity: quantity ?? this.quantity,
      claimedBy: claimedBy ?? this.claimedBy,
    );
  }
}