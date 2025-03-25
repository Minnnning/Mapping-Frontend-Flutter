import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserModel? get user => _user;

  /// 🔹 유저 정보 업데이트
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// 🔹 유저 정보 초기화 (로그아웃 시 사용)
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  /// 🔹 유저 정보 가져오기 (토큰 만료 시 자동 재발급 후 재시도)
  Future<void> fetchUser() async {
    try {
      String? accessToken = await _secureStorage.read(key: 'accessToken');
      if (accessToken == null) {
        print('🚫 액세스 토큰 없음, 로그인 필요');
        return;
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
        _user = UserModel(
          nickname: data['nickname'],
          profileImageUrl: data['profileImage'],
          role: data['role'],
          socialId: data['socialId'],
        );

        notifyListeners(); // 🔥 UI 업데이트
        print('✅ 유저 정보 갱신 성공');
      } else {
        print('❌ 유저 정보 가져오기 실패: ${response.data}');
      }
    } catch (error) {
      if (error is DioException && error.response?.statusCode == 400) {
        print('⚠️ 400 오류 발생! 토큰 재발급 시도...');
        bool tokenRefreshed = await refreshToken();
        if (tokenRefreshed) {
          print('🔄 토큰 재발급 성공! 유저 정보 다시 가져오기...');
          await fetchUser(); // ✅ 새 토큰으로 다시 요청
        } else {
          print('🚫 토큰 재발급 실패, 로그아웃 진행...');
          await logout();
        }
      } else {
        print('⚠️ 유저 정보 요청 중 오류 발생: $error');
      }
    }
  }

  /// 🔹 토큰 재발급
  Future<bool> refreshToken() async {
    try {
      String? refreshToken = await _secureStorage.read(key: 'refreshToken');
      if (refreshToken == null) {
        print('🚫 리프레시 토큰 없음, 로그인 필요');
        return false;
      }

      final response = await _dio.get(
        'https://api.mapping.kro.kr/api/v2/member/token-reissue',
        options: Options(headers: {
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
          print('✅ 새 토큰 저장 완료');
          return true;
        }
      }

      print('❌ 토큰 재발급 실패');
      return false;
    } catch (error) {
      print('⚠️ 토큰 재발급 중 오류 발생: $error');
      return false;
    }
  }

  /// 🔹 로그아웃
  Future<void> logout() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    clearUser(); // ✅ 유저 정보 초기화
    print('✅ 로그아웃 완료');
  }
}
