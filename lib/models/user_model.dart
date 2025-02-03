class UserModel {
  final String nickname;
  final String profileImageUrl;

  UserModel({required this.nickname, required this.profileImageUrl});

  factory UserModel.fromKakaoUser(dynamic kakaoUser) {
    return UserModel(
      nickname: kakaoUser.kakaoAccount?.profile?.nickname ?? 'Unknown',
      profileImageUrl: kakaoUser.kakaoAccount?.profile?.thumbnailImageUrl ?? '',
    );
  }
}
