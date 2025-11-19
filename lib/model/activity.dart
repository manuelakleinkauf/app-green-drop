import 'package:cloud_firestore/cloud_firestore.dart';

enum DonationStatus {
  pending,
  confirmed,
  rejected;

  String toFirestore() => name;
  static DonationStatus fromFirestore(String value) {
    return DonationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DonationStatus.pending,
    );
  }
}

class Activity {
  final String id;
  final String userId;
  final String type;
  final String description;
  final String location;
  final int points;
  final DateTime timestamp;
  final String? collectionPointId;
  final String? collectionPointName;
  final Map<String, int>? itemDetails; // Ex: {'Eletrônicos': 2, 'Baterias': 5}
  final DonationStatus status;
  final String? confirmedBy; // UID do voluntário/admin que confirmou
  final DateTime? confirmedAt;

  Activity({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.location,
    required this.points,
    required this.timestamp,
    this.collectionPointId,
    this.collectionPointName,
    this.itemDetails,
    this.status = DonationStatus.pending,
    this.confirmedBy,
    this.confirmedAt,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      points: data['points'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      collectionPointId: data['collectionPointId'],
      collectionPointName: data['collectionPointName'],
      itemDetails: data['itemDetails'] != null 
          ? Map<String, int>.from(data['itemDetails'])
          : null,
      status: data['status'] != null 
          ? DonationStatus.fromFirestore(data['status'])
          : DonationStatus.pending,
      confirmedBy: data['confirmedBy'],
      confirmedAt: data['confirmedAt'] != null 
          ? (data['confirmedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'description': description,
      'location': location,
      'points': points,
      'timestamp': Timestamp.fromDate(timestamp),
      if (collectionPointId != null) 'collectionPointId': collectionPointId,
      if (collectionPointName != null) 'collectionPointName': collectionPointName,
      if (itemDetails != null) 'itemDetails': itemDetails,
      'status': status.toFirestore(),
      if (confirmedBy != null) 'confirmedBy': confirmedBy,
      if (confirmedAt != null) 'confirmedAt': Timestamp.fromDate(confirmedAt!),
    };
  }

  int get totalItems => itemDetails?.values.fold<int>(0, (sum, qty) => sum + qty) ?? 0;
}