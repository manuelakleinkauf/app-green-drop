class UserModel {
  final String uid;
  final String name;
  final String email;
  final String accessProfile;
  final int points;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.accessProfile,
    required this.points,
  });

  factory UserModel.fromFirebase(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      accessProfile: data['accessProfile'] ?? '',
      points: data['points'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'accessProfile': accessProfile,
      'points': points,
    };
  }
}
