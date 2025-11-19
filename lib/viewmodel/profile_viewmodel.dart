import 'package:app/model/user.dart';
import 'package:app/model/activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../repository/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? user;
  bool isLoading = false;
  List<Activity> recentActivities = [];
  int userRanking = 0;
  List<UserModel> topUsers = [];

  ProfileViewModel({required this.repository});

  Future<void> loadUser(String uid) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await repository.getUserByUid(uid);
      await Future.wait([
        loadUserRanking(uid),
        loadRecentActivities(uid),
        loadTopUsers(),
      ]);
    } catch (e) {
      print('Error loading user data: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserRanking(String uid) async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .get();

      final index = usersSnapshot.docs.indexWhere((doc) => doc.id == uid);

      if (index != -1) {
        userRanking = index + 1;
      }
    } catch (e) {
      print('Error loading user ranking: $e');
    }
  }

  Future<void> loadRecentActivities(String uid) async {
    try {
      final activitiesSnapshot = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: uid)
          .limit(10)
          .get();

      recentActivities = activitiesSnapshot.docs
          .map((doc) => Activity.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading activities: $e');
    }
  }

  Future<void> loadTopUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .limit(10)
          .get();

      topUsers = snapshot.docs
          .map((doc) => UserModel.fromFirebase(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading top users: $e');
    }
  }
}
