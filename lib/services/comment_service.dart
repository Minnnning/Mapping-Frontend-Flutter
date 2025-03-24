import 'dart:convert';
import 'package:http/http.dart' as http;

class CommentService {
  static const String baseUrl = 'https://api.mapping.kro.kr/api/v2';
  static const String bearerToken = 'YOUR_ACCESS_TOKEN'; // 실제 토큰으로 교체

  /// 메모의 댓글 ID 목록을 가져오는 함수
  static Future<List<int>> fetchCommentIds(int memoId) async {
    final url = Uri.parse('$baseUrl/comment/ids?memoId=$memoId');
    final response = await http.get(url, headers: {'accept': '*/*'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<int> commentIds = List<int>.from(data['data']);
      return commentIds;
    } else {
      throw Exception('댓글 ID 목록 조회 실패');
    }
  }

  /// 단일 댓글 상세 정보를 가져오는 함수
  static Future<Map<String, dynamic>> fetchCommentDetail(int commentId) async {
    final url = Uri.parse('$baseUrl/comment/$commentId');
    final response = await http.get(url,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $bearerToken'});
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['data'];
    } else {
      throw Exception('댓글 상세 조회 실패');
    }
  }
}
