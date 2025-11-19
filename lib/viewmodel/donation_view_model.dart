import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/activity_repository.dart';

class DonationViewModel extends ChangeNotifier {
  final ActivityRepository _activityRepository = ActivityRepository(
    firestore: FirebaseFirestore.instance,
  );

  Future<void> registerDonation({
    required String userId,
    required String collectionPointId,
    required String collectionPointName,
    required Map<String, int> itemDetails,
  }) async {
    try {
      // Calcula total de itens e pontos
      final totalItems = itemDetails.values.fold(0, (sum, qty) => sum + qty);
      final points = totalItems * 100;

      // Cria descrição detalhada
      final itemsList = itemDetails.entries
          .map((e) => '${e.value}x ${e.key}')
          .join(', ');
      final description = 'Doação de $totalItems item${totalItems > 1 ? 's' : ''}: $itemsList';

      // Registra a atividade com status PENDENTE
      await _activityRepository.registerActivity(
        userId: userId,
        type: 'donation',
        description: description,
        location: collectionPointName,
        points: points,
        collectionPointId: collectionPointId,
        collectionPointName: collectionPointName,
        itemDetails: itemDetails,
      );

      // NÃO atualiza pontos do usuário - aguarda confirmação do ponto de coleta

      debugPrint("Doação registrada com status PENDENTE: $totalItems itens, $points pontos");
    } catch (e) {
      debugPrint("Erro ao registrar doação: $e");
      rethrow;
    }
  }
}
