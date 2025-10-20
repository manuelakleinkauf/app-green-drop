import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  late final AuthRepository _repository;

  bool isLoading = false;

  AuthViewModel() {
    _repository = AuthRepository();
  }

  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Erro ao fazer login.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String accessProfile,
    BuildContext context,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repository.register(
        email: email,
        password: password,
        name: name,
        accessProfile: accessProfile,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário registrado com sucesso!')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Erro ao registrar usuário.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro inesperado: $e')));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _repository.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail de redefinição enviado!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }
}
