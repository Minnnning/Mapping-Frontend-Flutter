import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MemoDeleteService {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// 엑세스 토큰을 가져오는 함수
  static Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  /// 메모를 삭제하는 함수
  static Future<bool> deleteMemo(int memoId) async {
    final String url = 'https://api.mapping.kro.kr/api/v2/memo/delete/$memoId';

    try {
      String? token = await _getAccessToken();

      Map<String, String> headers = {'accept': '*/*'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        print("⚠️ 엑세스 토큰 없음. 토큰 없이 요청을 보냅니다.");
      }

      final response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        print("✅ 메모 삭제 성공");
        return true;
      } else {
        print("❌ 삭제 실패: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ 예외 발생: $e");
      return false;
    }
  }
}
