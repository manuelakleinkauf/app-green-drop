import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/user_repository.dart';

class DonationViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository(
    firestore: FirebaseFirestore.instance,
  );

  Future<void> registerDonation(String donorEmail, int items) async {
    try {
      await _userRepository.addDonationPoints(donorEmail, items);
      debugPrint("Pontos adicionados para $donorEmail: ${items * 100}");
    } catch (e) {
      debugPrint("Erro ao adicionar pontos: $e");
    }
  }
}
