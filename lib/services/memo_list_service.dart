import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/memo_list_model.dart';

class MemoListService {
  final Dio _dio = Dio();
  final String baseUrl = "https://api.mapping.kro.kr/api/v2/memo";

  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// 🔹 SecureStorage에서 AccessToken 가져오기
  static Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  Future<List<MemoList>> fetchMyMemos() async {
    return _fetchMemos("$baseUrl/my-memo");
  }

  Future<List<MemoList>> fetchLikedMemos() async {
    return _fetchMemos("$baseUrl/liked");
  }

  Future<List<MemoList>> fetchCommentedMemos() async {
    return _fetchMemos("$baseUrl/commented");
  }

  Future<List<MemoList>> _fetchMemos(String url) async {
    try {
      final String? token = await _getAccessToken();
      if (token == null) {
        throw Exception("No access token found");
      }

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "accept": "*/*",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        List<dynamic> memoData = response.data['data'];
        return memoData.map((json) => MemoList.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load memos");
      }
    } catch (e) {
      print("Error fetching memos: $e");
      throw Exception("Error fetching memos");
    }
  }
}
