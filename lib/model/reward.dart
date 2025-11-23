import 'package:cloud_firestore/cloud_firestore.dart';

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final int quantity;
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> claimedBy;
  final bool isAvailable;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.quantity,
    required this.imageUrl,
    required this.createdAt,
    required this.claimedBy,
    required this.isAvailable,
  });

  factory Reward.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Reward(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      pointsCost: data['pointsCost'],
      quantity: data['quantity'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      claimedBy: List<String>.from(data['claimedBy'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    int? pointsCost,
    int? quantity,
    String? imageUrl,
    DateTime? createdAt,
    List<String>? claimedBy,
    bool? isAvailable,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsCost: pointsCost ?? this.pointsCost,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      claimedBy: claimedBy ?? this.claimedBy,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'pointsCost': pointsCost,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'claimedBy': claimedBy,
      'isAvailable': isAvailable,
    };
  }
}
