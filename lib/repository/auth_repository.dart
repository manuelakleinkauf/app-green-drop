import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository()
    : _auth = FirebaseAuth.instance,
      _firestore = FirebaseFirestore.instance {
    print('AuthRepository criado, _firestore: $_firestore');
  }

  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
    required String accessProfile,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      print('_firestore: $_firestore');
      print('user.uid: ${user?.uid}');

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'accessProfile': accessProfile,
        });
      }

      return userCredential;
    } catch (e) {
      print('Erro ao registrar usuário: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  User? getCurrentUser() => _auth.currentUser;

  Future<void> logout() => _auth.signOut();
}
