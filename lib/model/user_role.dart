enum UserRole {
  doador('DOADOR', 'Doador'),
  voluntario('VOLUNTARIO', 'Voluntário'),
  admin('ADMIN', 'Administrador');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value.toUpperCase(),
      orElse: () => UserRole.doador,
    );
  }

  // Permissões por role
  bool get canRegisterDonation => this == UserRole.doador || this == UserRole.admin;
  bool get canCreateCollectionPoint => this == UserRole.voluntario || this == UserRole.admin;
  bool get canEditAnyCollectionPoint => this == UserRole.admin;
  bool get canViewCollectionPointManagement => this == UserRole.voluntario || this == UserRole.admin;
}
