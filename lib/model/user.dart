import 'user_role.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String accessProfile; // Mantido para compatibilidade
  final UserRole role;
  final int points;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    String? accessProfile,
    UserRole? role,
    required this.points,
  })  : accessProfile = accessProfile ?? role?.value ?? UserRole.doador.value,
        role = role ?? UserRole.fromString(accessProfile ?? UserRole.doador.value);

  factory UserModel.fromFirebase(Map<String, dynamic> data) {
    final roleValue = data['accessProfile'] ?? data['role'] ?? 'DOADOR';
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.fromString(roleValue),
      points: data['points'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'accessProfile': role.value,
      'role': role.value,
      'points': points,
    };
  }

  // Métodos de conveniência para verificar permissões
  bool get canRegisterDonation => role.canRegisterDonation;
  bool get canCreateCollectionPoint => role.canCreateCollectionPoint;
  bool get canEditAnyCollectionPoint => role.canEditAnyCollectionPoint;
  bool get canViewCollectionPointManagement => role.canViewCollectionPointManagement;
  
  bool canEditCollectionPoint(String createdBy) {
    return role == UserRole.admin || createdBy == uid;
  }

  UserModel copyWith({
    String? name,
    String? email,
    UserRole? role,
    int? points,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      points: points ?? this.points,
    );
  }
}
