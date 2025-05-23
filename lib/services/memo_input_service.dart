import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MemoInputService {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// 엑세스 토큰을 가져오는 함수
  static Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  /// 메모 전송 API 호출 함수
  static Future<http.StreamedResponse?> submitMemo({
    required String title,
    required String content,
    required double lat,
    required double lng,
    required String category,
    required bool secret,
    required double currentLat,
    required double currentLng,
    required List<File> imageFiles, // 변경된 부분
  }) async {
    final uri = Uri.parse("https://api.mapping.kro.kr/api/v2/memo/new");
    final token = await _getAccessToken();

    var request = http.MultipartRequest('POST', uri);

    // 텍스트 필드 추가
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['lat'] = lat.toString();
    request.fields['lng'] = lng.toString();
    request.fields['category'] = category;
    request.fields['secret'] = secret.toString();
    request.fields['currentLat'] = currentLat.toString();
    request.fields['currentLng'] = currentLng.toString();

    // 여러 이미지 파일 추가 (없으면 아무것도 안 함)
    for (int i = 0; i < imageFiles.length; i++) {
      final image = imageFiles[i];
      final multipartFile = await http.MultipartFile.fromPath(
        'images', // 서버에서 같은 이름으로 여러 파일 받는 구조여야 함
        image.path,
        contentType: MediaType('image', 'png'),
      );
      request.files.add(multipartFile);
    }

    // 헤더 추가
    request.headers['accept'] = '*/*';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    } else {
      print("⚠️ 엑세스 토큰 없음. 토큰 없이 요청을 보냅니다.");
    }

    try {
      final response = await request.send();
      return response;
    } catch (e) {
      print("전송 중 오류 발생: $e");
      return null;
    }
  }
}
