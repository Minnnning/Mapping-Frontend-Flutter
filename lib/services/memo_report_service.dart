import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MemoReportService {
  static final _secureStorage = const FlutterSecureStorage();

  /// 엑세스 토큰을 가져오는 함수
  static Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  /// 메모 신고 요청
  static Future<bool> reportMemo({
    required int memoId,
    required String reportReason,
  }) async {
    final url =
        Uri.parse('https://api.mapping.kro.kr/api/v2/report/memo/report');
    try {
      final token = await _getAccessToken();
      final headers = <String, String>{
        'accept': '*/*',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        'memoId': memoId,
        'reportReason': reportReason,
      });

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('✅ 메모 신고 성공');
        return true;
      } else {
        print('❌ 메모 신고 실패: ${response.statusCode}');
        print('응답 본문: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ 메모 신고 중 예외 발생: $e');
      return false;
    }
  }
}
