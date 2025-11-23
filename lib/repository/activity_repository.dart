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
    String? collectionPointId,
    String? collectionPointName,
    Map<String, int>? itemDetails,
  }) async {
    try {
      final activity = Activity(
        id: '',
        userId: userId,
        type: type,
        description: description,
        location: location,
        points: points,
        timestamp: DateTime.now(),
        collectionPointId: collectionPointId,
        collectionPointName: collectionPointName,
        itemDetails: itemDetails,
      );

      // Usar set com doc gerado automaticamente para evitar conflitos
      final docRef = firestore.collection('activities').doc();
      await docRef.set(activity.toMap());
    } catch (e) {
      print('Erro ao registrar atividade: $e');
      rethrow;
    }
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

  // Buscar doações pendentes de um ponto de coleta
  Future<List<Activity>> getPendingDonations(String collectionPointId) async {
    final snapshot = await firestore
        .collection('activities')
        .where('collectionPointId', isEqualTo: collectionPointId)
        .where('status', isEqualTo: 'pending')
        .get();

    final activities = snapshot.docs
        .map((doc) => Activity.fromFirestore(doc))
        .toList();
    
    // Ordenar em memória por timestamp (mais recente primeiro)
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return activities;
  }

  // Confirmar doação e liberar pontos
  Future<void> confirmDonation({
    required String activityId,
    required String confirmedBy,
  }) async {
    final activityRef = firestore.collection('activities').doc(activityId);
    
    // Buscar a atividade
    final doc = await activityRef.get();
    if (!doc.exists) throw Exception('Atividade não encontrada');
    
    final activity = Activity.fromFirestore(doc);
    
    // Atualizar status da atividade
    await activityRef.update({
      'status': DonationStatus.confirmed.toFirestore(),
      'confirmedBy': confirmedBy,
      'confirmedAt': Timestamp.now(),
    });

    // Atualizar pontos do usuário
    final userRef = firestore.collection('users').doc(activity.userId);
    await firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;
      
      final currentPoints = userDoc.data()?['points'] ?? 0;
      transaction.update(userRef, {'points': currentPoints + activity.points});
    });
  }

  // Rejeitar doação
  Future<void> rejectDonation({
    required String activityId,
    required String rejectedBy,
  }) async {
    await firestore.collection('activities').doc(activityId).update({
      'status': DonationStatus.rejected.toFirestore(),
      'confirmedBy': rejectedBy,
      'confirmedAt': Timestamp.now(),
    });
  }
}