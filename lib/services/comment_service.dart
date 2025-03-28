import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommentService {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// 🔹 SecureStorage에서 AccessToken 가져오기
  static Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  /// 🔹 댓글 ID 목록 가져오기
  static Future<List<int>?> fetchCommentIds(int memoId) async {
    final url = Uri.parse(
        'https://api.mapping.kro.kr/api/v2/comment/ids?memoId=$memoId');

    String? token = await _getAccessToken();

    Map<String, String> headers = {'accept': '*/*'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      print("⚠️ 엑세스 토큰 없음. 토큰 없이 요청을 보냅니다.");
    }

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<int>.from(data['data']);
    } else {
      print("❌ 댓글 ID 요청 실패: ${response.statusCode}");
      return null;
    }
  }

  /// 🔹 댓글 상세 정보 가져오기
  static Future<List<Map<String, dynamic>>> fetchCommentDetails(
      List<int> commentIds) async {
    List<Map<String, dynamic>> fetchedComments = [];

    String? token = await _getAccessToken();

    for (int id in commentIds) {
      final url = Uri.parse('https://api.mapping.kro.kr/api/v2/comment/$id');

      Map<String, String> headers = {'accept': '*/*'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        fetchedComments.add(data['data']);
      }
    }
    return fetchedComments;
  }

  /// 🔹 새로운 댓글 생성
  static Future<bool> createComment({
    required String comment,
    required int memoId,
    int rating = 0,
  }) async {
    final url = Uri.parse(
      "https://api.mapping.kro.kr/api/v2/comment/new"
      "?comment=${Uri.encodeComponent(comment)}"
      "&memoId=$memoId"
      "&rating=$rating",
    );

    String? token = await _getAccessToken();

    Map<String, String> headers = {
      'accept': '*/*',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      url,
      headers: headers,
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData['success'] ?? false;
    } else {
      print("❌ 댓글 생성 실패: ${response.statusCode}, 응답: ${response.body}");
      return false;
    }
  }
}
