import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/user_repository.dart';
import '../repository/activity_repository.dart';

class DonationViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository(
    firestore: FirebaseFirestore.instance,
  );
  final ActivityRepository _activityRepository = ActivityRepository(
    firestore: FirebaseFirestore.instance,
  );

  Future<void> registerDonation(String donorEmail, int items) async {
    try {
      // Busca o usuário pelo email
      final user = await _userRepository.getUserByEmail(donorEmail);
      if (user == null) {
        throw Exception('Usuário não encontrado');
      }

      // Calcula os pontos
      final points = items * 100;

      // Adiciona os pontos ao usuário
      await _userRepository.addDonationPoints(donorEmail, items);

      // Registra a atividade
      await _activityRepository.registerActivity(
        userId: user.uid,
        type: 'donation',
        description: 'Doação de $items item${items > 1 ? 's' : ''}',
        location: 'Ponto de Coleta',
        points: points,
      );

      debugPrint("Pontos adicionados para $donorEmail: $points");
    } catch (e) {
      debugPrint("Erro ao registrar doação: $e");
      rethrow;
    }
  }
}
