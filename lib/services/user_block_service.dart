// lib/services/user_block_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// 차단된 사용자 정보를 담는 모델
class BlockedUser {
  final int userId;
  final String nickname;
  final String? profileImageUrl;

  BlockedUser({
    required this.userId,
    required this.nickname,
    this.profileImageUrl,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImage'] as String?,
    );
  }
}

/// 사용자 차단/차단 해제/차단 목록 조회를 담당하는 서비스
class UserBlockService {
  static final _secureStorage = const FlutterSecureStorage();

  /// 내부 helper: 엑세스 토큰 조회
  static Future<String?> _getAccessToken() async {
    return _secureStorage.read(key: 'accessToken');
  }

  /// 1) 사용자 차단
  /// 성공하면 true, 실패하면 false 반환
  static Future<bool> blockUser(int userId) async {
    final url = Uri.parse(
      'https://api.mapping.kro.kr/api/v2/member/block?userId=$userId',
    );
    try {
      final token = await _getAccessToken();
      final headers = <String, String>{
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        print('✅ 사용자 차단 성공 (userId=$userId)');
        return true;
      } else {
        print('❌ 사용자 차단 실패 (${response.statusCode})');
        return false;
      }
    } catch (e) {
      print('❌ 사용자 차단 중 예외 발생: $e');
      return false;
    }
  }

  /// 2) 차단된 유저 목록 조회
  /// 차단된 사용자 정보 리스트를 반환, 실패 시 Exception 던짐
  static Future<List<BlockedUser>> fetchBlockedUsers() async {
    final token = await _getAccessToken();
    final url =
        Uri.parse('https://api.mapping.kro.kr/api/v2/member/block/list');
    final response = await http.get(
      url,
      headers: {
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
// UTF-8로 디코딩해서 한글 깨짐 방지
      final decoded =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final List<dynamic> data = decoded['data'] as List<dynamic>;
      return data
          .map((e) => BlockedUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('차단된 사용자 목록 조회 실패: ${response.statusCode}');
    }
  }

  /// 3) 특정 유저 차단 해제
  /// 성공 시 true, 실패 시 false 반환
  static Future<bool> unblockUser(int userId) async {
    final token = await _getAccessToken();
    final url = Uri.parse(
      'https://api.mapping.kro.kr/api/v2/member/block/$userId',
    );
    final response = await http.delete(
      url,
      headers: {
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      print('✅ 사용자 차단 해제 성공 (userId=$userId)');
      return true;
    } else {
      print('❌ 사용자 차단 해제 실패 (${response.statusCode})');
      return false;
    }
  }
}
