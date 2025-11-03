import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/activity.dart';

class ActivityRepository {
  final FirebaseFirestore firestore;

  ActivityRepository({required this.firestore});

  Future<void> registerActivity({
    required String userId,
    required String type,
    required String description,
    required String location,
    required int points,
  }) async {
    final activity = Activity(
      id: '',
      userId: userId,
      type: type,
      description: description,
      location: location,
      points: points,
      timestamp: DateTime.now(),
    );

    await firestore.collection('activities').add(activity.toMap());
  }

  Future<List<Activity>> getRecentActivities(String userId, {int limit = 10}) async {
    final snapshot = await firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
  }
}