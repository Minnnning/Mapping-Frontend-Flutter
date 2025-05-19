import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MarkerService {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  static Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  static Future<Map<String, dynamic>> fetchMarkers(
    LatLng center,
    Function(Map<String, dynamic>) onTap,
  ) async {
    final String url =
        'https://api.mapping.kro.kr/api/v2/memo/total?lat=${center.latitude}&lng=${center.longitude}&km=5';

    try {
      String? token = await _getAccessToken();
      Map<String, String> headers = {'accept': '*/*'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          List memos = data['data'];
          Map<String, bool> secretMap = {};
          Set<Marker> markers = {};

          for (var memo in memos) {
            secretMap[memo['id'].toString()] = memo['secret'] == true;

            final icon = await _getCategoryIcon(memo['category']);

            markers.add(Marker(
              markerId: MarkerId(memo['id'].toString()),
              position: LatLng(memo['lat'], memo['lng']),
              infoWindow: InfoWindow(
                title: memo['title'],
                snippet: memo['category'],
              ),
              icon: icon,
              onTap: () => onTap(memo),
            ));
          }

          return {
            'markers': markers,
            'secretMap': secretMap,
          };
        }
      }
    } catch (e) {
      print("API 요청 오류: $e");
    }

    return {
      'markers': <Marker>{},
      'secretMap': <String, bool>{},
    };
  }

  static Future<BitmapDescriptor> _getCategoryIcon(String category) async {
    switch (category) {
      case '공용 화장실':
        return await BitmapDescriptor.asset(
            ImageConfiguration(), 'assets/icons/wc_icon.png');
      case '쓰레기통':
        return await BitmapDescriptor.asset(
            ImageConfiguration(), 'assets/icons/trash_icon.png');
      case '흡연장':
        return await BitmapDescriptor.asset(
            ImageConfiguration(), 'assets/icons/smoking_icon.png');
      case '주차장':
        return await BitmapDescriptor.asset(
            ImageConfiguration(), 'assets/icons/parking_icon.png');
      case '사진명소':
        return await BitmapDescriptor.asset(
            ImageConfiguration(), 'assets/icons/photo_icon.png');
      default:
        return await BitmapDescriptor.asset(
            ImageConfiguration(), 'assets/icons/guitar_icon.png');
    }
  }
}
