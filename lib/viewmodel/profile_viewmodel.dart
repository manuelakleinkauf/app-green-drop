import 'package:app/model/user.dart';
import 'package:flutter/material.dart';

import '../repository/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository repository;

  UserModel? user;
  bool isLoading = false;

  ProfileViewModel({required this.repository});

  Future<void> loadUser(String uid) async {
    isLoading = true;
    notifyListeners();

    user = await repository.getUserByUid(uid);

    isLoading = false;
    notifyListeners();
  }
}
