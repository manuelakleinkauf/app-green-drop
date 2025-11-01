import 'package:app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore firestore;

  UserRepository({required this.firestore});

  Future<UserModel?> getUserByUid(String uid) async {
    print("Buscando usuário com uid: $uid");
    final query = await firestore
        .collection('users')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      print("Usuário encontrado: ${query.docs.first.data()}");
      return UserModel.fromFirebase(query.docs.first.data());
    }
    print("Usuário não encontrado no Firestore");
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();
    return UserModel.fromFirebase(data);
  }

  Future<void> addDonationPoints(String email, int items) async {
    final userRef = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userRef.docs.isNotEmpty) {
      final docId = userRef.docs.first.id;
      final currentPoints = userRef.docs.first.data()['points'] ?? 0;
      final newPoints = currentPoints + (items * 100);

      await firestore.collection('users').doc(docId).update({
        'points': newPoints,
      });
    }
  }
}
