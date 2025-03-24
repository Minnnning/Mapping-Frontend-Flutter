import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MarkerDetailService {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// 엑세스 토큰을 가져오는 함수
  static Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  /// 메모 상세 정보를 가져오는 함수
  static Future<Map<String, dynamic>?> fetchMemoDetail(int memoId) async {
    final String url =
        'https://api.mapping.kro.kr/api/v2/memo/detail?memoId=$memoId';

    try {
      // 🔥 토큰 가져오기
      String? token = await _getAccessToken();

      // 기본 헤더 설정
      Map<String, String> headers = {'accept': '*/*'};

      // 토큰이 있다면 Authorization 헤더 추가
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        print("⚠️ 엑세스 토큰 없음. 토큰 없이 요청을 보냅니다.");
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          return data['data']; // 상세 메모 데이터 반환
        }
      } else {
        print("❌ API 요청 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ 메모 상세 조회 실패: $e");
    }
    return null;
  }
}
