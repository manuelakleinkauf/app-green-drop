import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String userId;
  final String type;
  final String description;
  final String location;
  final int points;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.location,
    required this.points,
    required this.timestamp,
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
    };
  }
}