//auth_service.dart
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 카카오 로그인
  Future<UserModel?> kakaoLogin(UserProvider userProvider) async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      print('카카오 로그인 성공 카카오 토큰: ${token.accessToken}');

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
        print('엑세스 토큰: ${newAccessToken}');
        UserModel user = UserModel.fromJson(data);
        userProvider.setUser(user); // ✅ 유저 정보 저장
        // try {
        //   var a = await _secureStorage.read(key: 'accessToken');
        //   var b = await _secureStorage.read(key: 'refreshToken');
        //   print(a);
        //   print(b);
        // } catch(error) {
        //   print(error);
        // }
        print('서버 로그인 성공, 토큰 저장 완료');
        return user;
      } else {
        print('서버 로그인 실패: ${response.data}');
        return null;
      }
    } catch (error) {
      print('카카오 로그인 실패: $error');
      return null;
    }
  }

  //구글 로그인
  Future<UserModel?> googleLogin(UserProvider userProvider) async {
  try {
    await dotenv.load(fileName: '.env');
    final serverClientId = dotenv.env['ANDROID_CLIENT_ID'];

    if (serverClientId == null) {
      throw Exception('ANDROID_CLIENT_ID is not set in the .env file');
    }

    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: serverClientId, // serverClientId 지정
    );

    // 1) 구글 로그인 UI
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      print('Google 로그인 취소');
      return null;
    }

    // 2) Authorization Code 바로 꺼내기
    final String? authCode = googleUser.serverAuthCode;
    print('DEBUG serverAuthCode: $authCode');

    if (authCode == null) {
      print('❌ serverAuthCode 획득 실패');
      return null;
    }

    // 3) 서버에 code 파라미터로 전송
    final response = await _dio.post(
      'https://api.mapping.kro.kr/api/v2/member/google-login',
      options: Options(headers: {'accept': '*/*'}),
      queryParameters: {'code': authCode},
      data: {},
    );

    // 4) 응답 처리
    if (response.statusCode == 200 && response.data['success']) {
      final data = response.data['data'];
      final String newAccessToken = data['tokens']['accessToken'];
      final String refreshToken = data['tokens']['refreshToken'];

      await _secureStorage.write(key: 'accessToken', value: newAccessToken);
      await _secureStorage.write(key: 'refreshToken', value: refreshToken);
      final user = UserModel.fromJson(data);
      userProvider.setUser(user);
      print('서버 토큰 저장 완료 (Google)');
      return user;
    } else {
      print('서버 로그인 실패 (Google): ${response.data}');
      return null;
    }
  } catch (e) {
    print('Google 로그인 에러: $e');
    return null;
  }
}


  // 유저 정보 가져오기
  Future<UserModel?> fetchUser(UserProvider userProvider) async {
    try {
      String? accessToken = await _secureStorage.read(key: 'accessToken');
      print(accessToken);
      if (accessToken == null) {
        print('액세스 토큰 없음, 로그인 필요');
        return null;
      }

      final response = await _dio.get(
        'https://api.mapping.kro.kr/api/v2/member/user-info',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'accept': 'application/json',
        }),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        UserModel user = UserModel(
          nickname: data['nickname'],
          profileImageUrl: data['profileImage'] ?? '',
          role: data['role'],
          socialId: data['socialId'],
        );

        userProvider.setUser(user);
        print('유저 정보 갱신 성공');
        return user;
      } else {
        print('유저 정보 가져오기 실패: ${response.data}');
        return null;
      }
    } catch (error) {
      if (error is DioException) {
        if (error.response?.statusCode == 401) {
          print('유저 정보 요청 실패 (401), 토큰 재발급 시도');
          return await expiredToken(userProvider);
        }
      }
      print('유저 정보 요청 중 오류 발생: $error');
      return null;
    }
  }

  // 로그아웃
  Future<void> logout(UserProvider userProvider) async {
    try {
      await _secureStorage.delete(key: 'accessToken');
      await _secureStorage.delete(key: 'refreshToken');

      userProvider.clearUser(); // ✅ 유저 정보 초기화

      //GoogleSignIn 세션 완전 해제
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email','profile'],
      );
      await googleSignIn.disconnect();

      print('로그아웃 완료');
    } catch (error) {
      print('로그아웃 실패: $error');
    }
  }

  // 토큰 재발급
  Future<UserModel?> expiredToken(UserProvider userProvider) async {
    try {
      String? oldAccessToken = await _secureStorage.read(key: 'accessToken');
      String? refreshToken = await _secureStorage.read(key: 'refreshToken');

      final response = await _dio.get(
        'https://api.mapping.kro.kr/api/v2/member/token-reissue',
        options: Options(headers: {
          'Authorization': 'Bearer $oldAccessToken',
          'Authorization-Refresh': 'Bearer $refreshToken',
          'accept': '*/*',
        }),
      );

      if (response.statusCode == 200 && response.data['success']) {
        String? newAccessToken = response.headers['authorization']?.first
            .replaceFirst('Bearer ', '');
        String? newRefreshToken = response
            .headers['authorization-refresh']?.first
            .replaceFirst('Bearer ', '');

        if (newAccessToken != null && newRefreshToken != null) {
          await _secureStorage.write(key: 'accessToken', value: newAccessToken);
          await _secureStorage.write(
              key: 'refreshToken', value: newRefreshToken);
          print('새 토큰 저장 완료');

          // 토큰 갱신 후 유저 정보 다시 가져오기
          return await fetchUser(userProvider);
        }
      }

      // 예외 상황: 토큰 재발급 실패 시 로그아웃 처리
      print('토큰 재발급 실패, 로그아웃 진행');
      await logout(userProvider);
      return null;
    } catch (error) {
      print('토큰 재발급 오류: $error');

      // 에러 발생 시 로그아웃 처리
      await logout(userProvider);
      return null;
    }
  }

  // 회원 탈퇴
  Future<bool> withdraw(UserProvider userProvider) async {
    try {
      String? accessToken = await _secureStorage.read(key: 'accessToken');

      if (accessToken == null) {
        print('회원 탈퇴 실패: 액세스 토큰 없음');
        return false;
      }

      final response = await _dio.delete(
        'https://api.mapping.kro.kr/api/v2/member/withdraw',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        print('회원 탈퇴 성공');

        // 탈퇴 후 토큰 삭제 및 유저 정보 초기화
        await logout(userProvider);

        return true;
      } else {
        print('회원 탈퇴 실패: ${response.data}');
        return false;
      }
    } catch (error) {
      print('회원 탈퇴 중 오류 발생: $error');
      return false;
    }
  }
}
