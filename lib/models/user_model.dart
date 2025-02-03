class UserModel {
  final String nickname;
  final String profileImageUrl;
  final String role;
  final String socialId;

  UserModel({
    required this.nickname,
    required this.profileImageUrl,
    required this.role,
    required this.socialId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nickname: json['nickname'],
      profileImageUrl: json['profileImage'] ?? '',
      role: json['role'],
      socialId: json['socialId'],
    );
  }
}