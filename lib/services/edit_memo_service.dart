import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class EditMemoService {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  static Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  /// 메모 수정 요청
  static Future<bool> updateMemo({
    required int memoId,
    required String title,
    required String content,
    required String category,
    required List<File> images,
    required List<String> deleteImageUrls,
  }) async {
    final String url = 'https://api.mapping.kro.kr/api/v2/memo/update/$memoId';

    try {
      String? token = await _getAccessToken();

      final request = http.MultipartRequest('PUT', Uri.parse(url));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      } else {
        print("⚠️ 토큰 없음. 인증 없이 요청을 보냅니다.");
      }

      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['category'] = category;

      for (var imageFile in images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      for (var url in deleteImageUrls) {
        request.fields['deleteImageUrls'] = url;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print("✅ 메모 수정 성공");
        return true;
      } else {
        print("❌ 메모 수정 실패: ${response.statusCode}");
        print("응답 내용: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ 예외 발생: $e");
      return false;
    }
  }
}
