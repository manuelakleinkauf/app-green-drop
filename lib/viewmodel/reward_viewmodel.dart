import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/reward.dart';

class RewardViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Reward> _rewards = [];
  bool isLoading = false;

  List<Reward> get rewards => _rewards;
  List<Reward> get availableRewards => _rewards.where((r) => r.isAvailable && r.hasAvailableQuantity).toList();

  RewardViewModel() {
    _listenToRewards();
  }

  void _listenToRewards() {
    _firestore.collection('rewards').snapshots().listen((snapshot) {
      _rewards = snapshot.docs
          .map((doc) => Reward.fromFirestore(doc))
          .toList();
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
    isLoading = true;
    notifyListeners();

    try {
      final reward = Reward(
        id: '',
        title: title,
        description: description,
        pointsCost: pointsCost,
        quantity: quantity,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        claimedBy: [],
      );

      await _firestore.collection('rewards').add(reward.toMap());
    } catch (e) {
      print('Erro ao adicionar recompensa: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReward(Reward reward) async {
    isLoading = true;
    notifyListeners();

    try {
      await _firestore
          .collection('rewards')
          .doc(reward.id)
          .update(reward.toMap());
    } catch (e) {
      print('Erro ao atualizar recompensa: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> claimReward(String rewardId, String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      final reward = _rewards.firstWhere((r) => r.id == rewardId);
      
      if (!reward.hasAvailableQuantity) {
        throw Exception('Recompensa esgotada');
      }

      if (reward.claimedBy.contains(userId)) {
        throw Exception('Você já resgatou esta recompensa');
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userPoints = userDoc.data()?['points'] ?? 0;

      if (userPoints < reward.pointsCost) {
        throw Exception('Pontos insuficientes');
      }

      // Atualiza a recompensa
      await _firestore.collection('rewards').doc(rewardId).update({
        'claimedBy': FieldValue.arrayUnion([userId]),
      });

      // Deduz os pontos do usuário
      await _firestore.collection('users').doc(userId).update({
        'points': FieldValue.increment(-reward.pointsCost),
      });

    } catch (e) {
      print('Erro ao resgatar recompensa: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}