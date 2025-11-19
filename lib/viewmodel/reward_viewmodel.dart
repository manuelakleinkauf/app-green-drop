import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/reward.dart';

class RewardViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Reward> _rewards = [];
  bool isLoading = false;

  List<Reward> get rewards => _rewards;
  List<Reward> get availableRewards =>
      _rewards.where((r) => r.isAvailable && r.quantity > 0).toList();

  RewardViewModel() {
    _listenToRewards();
  }

  void _listenToRewards() {
    _firestore.collection('rewards').snapshots().listen((snapshot) {
      _rewards = snapshot.docs.map((doc) {
        return Reward.fromFirestore(doc);
      }).toList();

      notifyListeners();
    });
  }

  Future<void> addReward(
    String title,
    String description,
    int pointsCost,
    int quantity,
    String? imageUrl,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      final reward = Reward(
        id: "",
        title: title,
        description: description,
        pointsCost: pointsCost,
        quantity: quantity,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        claimedBy: [],
        isAvailable: true,
      );

      await _firestore.collection('rewards').add(reward.toMap());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> claimReward(String rewardId, String userId) async {
    try {
      isLoading = true;
      notifyListeners();

      final reward = _rewards.firstWhere((r) => r.id == rewardId);

      if (reward.quantity <= 0) {
        throw Exception('Recompensa esgotada');
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userPoints = userDoc.data()?['points'] ?? 0;

      if (userPoints < reward.pointsCost) {
        throw Exception('Pontos insuficientes');
      }

      await _firestore.collection('rewards').doc(rewardId).update({
        'quantity': reward.quantity - 1,
      });

      await _firestore
          .collection('users')
          .doc(userId)
          .update({'points': FieldValue.increment(-reward.pointsCost)});

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('rewardHistory')
          .add({
        'rewardId': rewardId,
        'title': reward.title,
        'imageUrl': reward.imageUrl,
        'pointsSpent': reward.pointsCost,
        'claimedAt': Timestamp.now(),
      });
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<Map<String, dynamic>>> rewardHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('rewardHistory')
        .snapshots()
        .map((snap) {
          final rewards = snap.docs
              .map((doc) => doc.data())
              .toList();
          
          // Ordenar em memória por claimedAt (mais recente primeiro)
          rewards.sort((a, b) {
            final aTime = (a['claimedAt'] as Timestamp?)?.toDate() ?? DateTime(1970);
            final bTime = (b['claimedAt'] as Timestamp?)?.toDate() ?? DateTime(1970);
            return bTime.compareTo(aTime);
          });
          
          return rewards;
        });
  }
}
