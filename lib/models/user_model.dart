class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String instagram;
  final String photoUrl;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.instagram = '',
    this.photoUrl = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      instagram: map['instagram'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'instagram': instagram,
      'photoUrl': photoUrl,
    };
  }
}
