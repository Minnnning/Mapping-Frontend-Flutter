import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';

class ChangeInfoService {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// 엑세스 토큰 가져오기
  static Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  /// 닉네임 변경 요청
  static Future<bool> updateNickname(String nickname) async {
    String? token = await _getAccessToken();
    if (token == null) return false;

    final uri = Uri.parse(
        'https://api.mapping.kro.kr/api/v2/member/modify-nickname?nickname=$nickname');

    final response = await http.patch(
      uri,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  /// 프로필 이미지 변경 요청
  static Future<bool> updateProfileImage(File imageFile) async {
    String? token = await _getAccessToken();
    if (token == null) return false;

    final uri = Uri.parse(
        'https://api.mapping.kro.kr/api/v2/member/modify-profile-image');
    final request = http.MultipartRequest('PATCH', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['accept'] = '*/*'
      ..files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'), // 혹은 사용자가 선택한 확장자에 따라 다르게 처리
      ));

    final response = await request.send();
    return response.statusCode == 200;
  }
}
