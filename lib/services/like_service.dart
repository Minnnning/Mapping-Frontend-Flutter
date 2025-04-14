import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LikeService {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// 엑세스 토큰을 가져오는 함수
  static Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  /// 메모 좋아요 요청 함수
  static Future<bool> likeMemo(int memoId) async {
    final String url = 'https://api.mapping.kro.kr/api/v2/memo/like/$memoId';
    return await _postMemoAction(url, action: "좋아요");
  }

  /// 메모 싫어요 요청 함수
  static Future<bool> hateMemo(int memoId) async {
    final String url = 'https://api.mapping.kro.kr/api/v2/memo/hate/$memoId';
    return await _postMemoAction(url, action: "싫어요");
  }

  /// 댓글 좋아요 요청 함수
  static Future<bool> likeComment(int commentId) async {
    final String url =
        'https://api.mapping.kro.kr/api/v2/comment/like/$commentId';
    return await _postMemoAction(url, action: "댓글 좋아요");
  }

  /// 공통 POST 요청 처리 함수
  static Future<bool> _postMemoAction(String url,
      {required String action}) async {
    try {
      String? token = await _getAccessToken();

      // 토큰이 없으면 요청하지 않고 false 반환
      if (token == null) {
        print("❌ $action 실패: 엑세스 토큰이 없습니다.");
        return false;
      }

      Map<String, String> headers = {
        'accept': '*/*',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({}), // 비어있는 JSON body
      );

      if (response.statusCode == 200) {
        print("✅ $action 요청 성공");
        return true;
      } else {
        print("❌ $action 요청 실패: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ $action 요청 중 예외 발생: $e");
      return false;
    }
  }
}
