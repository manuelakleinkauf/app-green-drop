import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user.dart';
import '../model/user_role.dart';
import '../repository/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  final UserRepository _userRepository = UserRepository(firestore: FirebaseFirestore.instance);
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  UserRole get userRole => _currentUser?.role ?? UserRole.doador;

  // Atalhos para permissões
  bool get canRegisterDonation => _currentUser?.canRegisterDonation ?? false;
  bool get canCreateCollectionPoint => _currentUser?.canCreateCollectionPoint ?? false;
  bool get canEditAnyCollectionPoint => _currentUser?.canEditAnyCollectionPoint ?? false;
  bool get canViewCollectionPointManagement => _currentUser?.canViewCollectionPointManagement ?? false;

  CurrentUserProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _currentUser = await _userRepository.getUserByUid(firebaseUser.uid);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  bool canEditCollectionPoint(String createdBy) {
    return _currentUser?.canEditCollectionPoint(createdBy) ?? false;
  }

  void clear() {
    _currentUser = null;
    notifyListeners();
  }
}
