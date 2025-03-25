import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../providers/user_provider.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// 🔹 카카오 로그인
  Future<void> login(UserProvider userProvider) async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      print('✅ 카카오 로그인 성공: ${token.accessToken}');

      final response = await _dio.post(
        'https://api.mapping.kro.kr/api/v2/member/login',
        options: Options(
            headers: {'accept': '*/*', 'Content-Type': 'application/json'}),
        data: {'accessToken': token.accessToken},
      );

      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        String newAccessToken = data['tokens']['accessToken'];
        String refreshToken = data['tokens']['refreshToken'];

        await _secureStorage.write(key: 'accessToken', value: newAccessToken);
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);

        print('✅ 서버 로그인 성공, 토큰 저장 완료');

        // 🔥 로그인 후 유저 정보 자동 가져오기
        await userProvider.fetchUser();
      } else {
        print('❌ 서버 로그인 실패: ${response.data}');
      }
    } catch (error) {
      print('⚠️ 카카오 로그인 실패: $error');
    }
  }

  /// 🔹 로그아웃
  Future<void> logout(UserProvider userProvider) async {
    try {
      await _secureStorage.delete(key: 'accessToken');
      await _secureStorage.delete(key: 'refreshToken');

      userProvider.clearUser(); // ✅ 유저 정보 초기화
      print('✅ 로그아웃 완료');
    } catch (error) {
      print('❌ 로그아웃 실패: $error');
    }
  }
}
