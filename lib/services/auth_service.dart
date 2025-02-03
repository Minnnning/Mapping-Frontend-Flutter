import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import '../models/user_model.dart';

class AuthService {
  Future<UserModel?> login() async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      print('카카오 로그인 성공: ${token.accessToken}');
      return fetchUserInfo();
    } catch (error) {
      print('카카오 로그인 실패: $error');
      return null;
    }
  }

  Future<UserModel?> fetchUserInfo() async {
    try {
      User user = await UserApi.instance.me();
      return UserModel.fromKakaoUser(user);
    } catch (error) {
      print('사용자 정보 가져오기 실패: $error');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
    } catch (error) {
      print('로그아웃 실패: $error');
    }
  }
}
