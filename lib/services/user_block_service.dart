// lib/services/user_block_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserBlockService {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// 엑세스 토큰을 가져오는 내부 helper
  static Future<String?> _getAccessToken() async {
    return _secureStorage.read(key: 'accessToken');
  }

  /// 사용자 차단 API 호출
  /// 성공하면 true, 실패하면 false 반환
  static Future<bool> blockUser(int userId) async {
    final url = Uri.parse(
      'https://api.mapping.kro.kr/api/v2/member/block?userId=$userId',
    );
    try {
      final token = await _getAccessToken();
      final headers = <String, String>{
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        print('✅ 사용자 차단 성공 (userId=$userId)');
        return true;
      } else {
        print('❌ 사용자 차단 실패 (${response.statusCode})');
        return false;
      }
    } catch (e) {
      print('❌ 사용자 차단 중 예외 발생: $e');
      return false;
    }
  }
}
