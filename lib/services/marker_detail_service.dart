import 'dart:convert';
import 'package:http/http.dart' as http;

class MarkerDetailService {
  static Future<Map<String, dynamic>?> fetchMemoDetail(int memoId) async {
    final String url =
        'https://api.mapping.kro.kr/api/v2/memo/detail?memoId=$memoId';

    try {
      final response =
          await http.get(Uri.parse(url), headers: {'accept': '*/*'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          return data['data']; // 상세 메모 데이터 반환
        }
      }
    } catch (e) {
      print("메모 상세 조회 실패: $e");
    }
    return null;
  }
}
